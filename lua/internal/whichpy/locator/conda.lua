local util = require('internal.whichpy.util')
local is_win = util.is_win
local get_interpreter_path = util.get_interpreter_path
local get_env_var_strategy = require('internal.whichpy.locator._common').get_env_var_strategy
local InterpreterInfo = require('internal.whichpy.locator').InterpreterInfo

local Locator = { name = 'conda' }
Locator.__index = Locator

function Locator.new(opts)
  local obj = vim.tbl_deep_extend('force', {
    display_name = 'Conda',
    get_env_var_strategy = get_env_var_strategy.conda,
  }, opts or {})
  return setmetatable(obj, Locator)
end

function Locator:find(Job)
  return coroutine.wrap(function()
    if vim.fn.executable('conda') == 0 then
      return
    end
    vim.system({ 'conda', 'info', '--json' }, {}, function(out)
      local ctx = { locator_name = self.name }
      if out.code ~= 0 then
        ctx.err = 'conda command error'
      else
        local ok, envs = pcall(vim.json.decode, out.stdout)
        if ok then
          envs = envs.envs
          if envs then
            ctx.co = function()
              return self:_find(envs)
            end
          end
        else
          ctx.err = 'conda output is not json'
        end
      end
      Job:continue(ctx)
    end)
    coroutine.yield({ locator_name = self.name, wait = true })
  end)
end

function Locator:_find(envs)
  return coroutine.wrap(function()
    for _, env in ipairs(envs) do
      local path = get_interpreter_path(env, is_win and 'root' or 'bin')
      if vim.uv.fs_stat(path) then
        coroutine.yield(InterpreterInfo:new(self, path))
      end
    end
  end)
end

return Locator
