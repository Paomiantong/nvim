---@class InternalWhichPy.TyHandler: InternalWhichPy.LspHandler
---@field snapshot? { python_path: string|nil }
---@field server_default? { python_path: string|nil }
local M = {}
M.__index = M

function M.new()
  local obj = {
    server_default = {
      -- ty 默认会自己推断（VIRTUAL_ENV / conda / .venv 等），所以这里保持 nil
      python_path = nil,
    },
  }
  return setmetatable(obj, M)
end

-- 读取当前 client 上的 ty python 配置（ty.configuration.environment.python）
local function get_ty_python_path_from_settings(settings)
  local ty = settings.ty
  if type(ty) ~= 'table' then
    return nil
  end

  local cfg = ty.configuration
  if type(cfg) ~= 'table' then
    return nil
  end

  local env = cfg.environment
  if type(env) ~= 'table' then
    return nil
  end

  return env.python
end

-- 写入/清理 ty python 配置（ty.configuration.environment.python）
local function set_ty_python_path_on_settings(settings, python_path)
  settings.ty = settings.ty or {}
  settings.ty.configuration = settings.ty.configuration or {}
  settings.ty.configuration.environment = settings.ty.configuration.environment or {}

  settings.ty.configuration.environment.python = python_path
end

local function persist_ty_settings(client)
  if type(vim.lsp.config) ~= 'function' then
    return
  end

  pcall(vim.lsp.config, client.name, {
    settings = client.config.settings,
  })
end

-- 尽量兼容不同 Nvim 版本的 restart 命令
local function restart_lsp_client(client)
  -- Nvim 新命令：:lsp restart <client_name>
  local ok = pcall(function()
    if vim.cmd.lsp then
      -- 等价于 :lsp restart {client.name}
      vim.cmd.lsp({ 'restart', client.name })
      return true
    end
    error('vim.cmd.lsp not available')
  end)
  if ok then
    return
  end

  -- 旧命令：:LspRestart <client_id>
  pcall(vim.cmd, ('LspRestart %s'):format(client.id))
end

function M:snapshot_settings(client)
  if self.snapshot ~= nil then
    return
  end
  self.snapshot = {}

  -- 优先从 client.settings 读；没有则退回 client.config.settings
  local settings = nil
  if type(client.settings) == 'table' then
    settings = client.settings
  elseif type(client.config) == 'table' and type(client.config.settings) == 'table' then
    settings = client.config.settings
  end

  if settings then
    self.snapshot.python_path = get_ty_python_path_from_settings(settings)
  else
    self.snapshot.python_path = self.server_default.python_path
  end
end

function M:restore_snapshot(client)
  -- 传 nil 会回落到 snapshot.python_path
  self:set_python_path(client, nil)
end

function M:set_python_path(client, python_path, opts)
  python_path = python_path or (self.snapshot and self.snapshot.python_path) or self.server_default.python_path

  client.config.settings = client.config.settings or {}
  local current_python_path = get_ty_python_path_from_settings(client.config.settings)
  set_ty_python_path_on_settings(client.config.settings, python_path)
  persist_ty_settings(client)

  if type(client.settings) == 'table' then
    set_ty_python_path_on_settings(client.settings, python_path)
  end

  if opts and opts.restart == false then
    return
  end

  if current_python_path ~= python_path then
    restart_lsp_client(client)
  end
end

return M
