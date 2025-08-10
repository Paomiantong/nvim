local config = require('internal.whichpy.config').config
local util = require('internal.whichpy.util')
local is_win = util.is_win
local SearchJob = require('internal.whichpy.search')
local final_envs = {}
local orig_interpreter_path
local curr_interpreter_path
local env_name = nil
local InterpreterInfo = require('internal.whichpy.locator').InterpreterInfo

local M = {}

M.set_envs = function(envs)
  final_envs = envs
end

M.get_envs = function()
  if SearchJob:status() == 'dead' then
    return final_envs
  end
  return SearchJob._temp_envs
end

---@param selected InternalWhichPy.InterpreterInfo
---@param should_cache? boolean
M.handle_select = function(selected, should_cache)
  local should_backup_original = orig_interpreter_path == nil
  local _orig_interpreter_path = {}
  should_cache = should_cache == nil or should_cache

  if should_backup_original then
    _orig_interpreter_path['dap'] = {}
    _orig_interpreter_path['envvar'] = {
      CONDA_PREFIX = vim.env.CONDA_PREFIX,
      VIRTUAL_ENV = vim.env.VIRTUAL_ENV,
    }
  end

  -- lsp
  for lsp_name, handler in pairs(config.lsp) do
    local client = vim.lsp.get_clients({ name = lsp_name })[1]
    if client then
      if should_backup_original then
        handler:snapshot_settings(client)
      end
      handler:set_python_path(client, selected.path)
    end
  end

  -- dap
  local ok, dap_python = pcall(require, 'dap-python')
  if ok then
    if should_backup_original then
      _orig_interpreter_path['dap'] = dap_python.resolve_python
    end
    dap_python.resolve_python = function()
      return selected.path
    end
  end

  -- $VIRTUAL_ENV, $CONDA_PREFIX
  local env_var = selected:env_var()
  if env_var.name == 'VIRTUAL_ENV' then
    vim.env.VIRTUAL_ENV = env_var.val
    vim.env.CONDA_PREFIX = nil
  elseif env_var.name == 'CONDA_PREFIX' then
    vim.env.VIRTUAL_ENV = nil
    vim.env.CONDA_PREFIX = env_var.val
  else
    vim.env.VIRTUAL_ENV = nil
    vim.env.CONDA_PREFIX = nil
  end
  env_name = selected:env_name()
  util.notify_chenv('Venv', vim.env.VIRTUAL_ENV)
  util.notify_chenv('Conda', vim.env.CONDA_PREFIX)

  -- $PATH
  if config.update_path_env then
    local delimiter = (is_win and ';') or ':'
    if not should_backup_original then
      vim.env.PATH = vim.env.PATH:gsub(vim.fs.dirname(curr_interpreter_path) .. delimiter, '', 1)
    end
    vim.env.PATH = vim.fs.dirname(selected.path) .. delimiter .. vim.env.PATH

    util.notify('Prepend ' .. vim.fs.dirname(selected.path) .. ' to $PATH.')
  end

  -- cache
  if should_cache then
    vim.fn.mkdir(config.cache_dir, 'p')
    local filename = vim.fn.getcwd():gsub('[\\/:]+', '%%')
    local f = assert(io.open(vim.fs.joinpath(config.cache_dir, filename), 'wb'))
    f:write(selected.path .. '\n' .. selected.locator_name .. '\n' .. selected.version)
    f:close()
  end

  if should_backup_original then
    orig_interpreter_path = _orig_interpreter_path
  end
  curr_interpreter_path = selected.path

  if config.after_handle_select then
    config.after_handle_select(selected)
  end
end

M.handle_reset = function()
  if orig_interpreter_path == nil then
    return
  end

  -- lsp
  for lsp_name, handler in pairs(config.lsp) do
    local client = vim.lsp.get_clients({ name = lsp_name })[1]
    if client then
      handler:restore_snapshot(client)
    end
  end

  -- dap
  local ok, dap_python = pcall(require, 'dap-python')
  if ok then
    dap_python.resolve_python = orig_interpreter_path.dap
  end

  -- $VIRTUAL_ENV, $CONDA_PREFIX
  vim.env.VIRTUAL_ENV = orig_interpreter_path.envvar.VIRTUAL_ENV
  vim.env.CONDA_PREFIX = orig_interpreter_path.envvar.CONDA_PREFIX

  util.notify_chenv('Venv', vim.env.VIRTUAL_ENV)
  util.notify_chenv('Conda', vim.env.CONDA_PREFIX)

  -- $PATH
  if config.update_path_env then
    local delimiter = (is_win and ';') or ':'
    vim.env.PATH = vim.env.PATH:gsub(vim.fs.dirname(curr_interpreter_path) .. delimiter, '', 1)
  end

  -- cache
  local filename = vim.fn.getcwd():gsub('/', '%%')
  os.remove(vim.fs.joinpath(config.cache_dir, filename))

  orig_interpreter_path = nil
  curr_interpreter_path = nil
end

M.retrieve_cache = function()
  local filename = vim.fn.getcwd():gsub('/', '%%')
  local f = io.open(vim.fs.joinpath(config.cache_dir, filename), 'r')
  if not f then
    return
  end
  local lines = {}
  local line = f:read()
  while line do
    table.insert(lines, line)
    line = f:read()
  end
  f:close()

  M.handle_select(
    InterpreterInfo:new(require('internal.whichpy.locator').get_locator(lines[2] or 'global'), lines[1], lines[3]),
    false
  )
end

M.current_selected = function()
  return curr_interpreter_path
end

M.current_selected_name = function()
  return env_name
end

M.clear_cache = function()
  if not vim.fn.isdirectory(config.cache_dir) then
    return
  end
  local files = vim.fn.readdir(config.cache_dir)
  for _, file in ipairs(files) do
    os.remove(vim.fs.joinpath(config.cache_dir, file))
  end
  util.notify('Whichpy Cache cleared.')
end

return M
