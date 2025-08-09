local util = require('internal.whichpy.util')
local get_interpreter_path = util.get_interpreter_path
local get_env_var_strategy = require('internal.whichpy.locator._common').get_env_var_strategy
local get_pyenv_version_dir = require('internal.whichpy.locator._common').get_pyenv_version_dir
local InterpreterInfo = require('internal.whichpy.locator').InterpreterInfo

local Locator = { name = 'pyenv' }
Locator.__index = Locator

function Locator.new(opts)
  local obj = vim.tbl_deep_extend('force', {
    display_name = 'Pyenv',
    get_env_var_strategy = get_env_var_strategy.pyenv,
    venv_only = true,
  }, opts or {})
  return setmetatable(obj, Locator)
end

function Locator:find()
  return coroutine.wrap(function()
    local dir = get_pyenv_version_dir()
    for name, t in vim.fs.dir(dir) do
      if t == 'directory' then
        local path = get_interpreter_path(vim.fs.joinpath(dir, name), 'bin')
        if vim.uv.fs_stat(path) then
          if not self.venv_only then
            coroutine.yield(InterpreterInfo:new(self, path))
          end
          local envs_dir = vim.fs.joinpath(dir, name, 'envs')
          for name2, t2 in vim.fs.dir(envs_dir) do
            if t2 == 'directory' then
              local path2 = get_interpreter_path(vim.fs.joinpath(envs_dir, name2), 'bin')
              if vim.uv.fs_stat(path2) then
                coroutine.yield(InterpreterInfo:new(self, path2))
              end
            end
          end
        end
      end
    end
  end)
end

return Locator
