local util = require('internal.whichpy.util')
local is_win = util.is_win
local get_interpreter_path = util.get_interpreter_path
local get_env_var_strategy = require('internal.whichpy.locator._common').get_env_var_strategy
local InterpreterInfo = require('internal.whichpy.locator').InterpreterInfo

local DEFAULT_BINARIES = { 'conda', 'mamba', 'micromamba' }

local Locator = { name = 'conda' }
Locator.__index = Locator

function Locator.new(opts)
  local obj = vim.tbl_deep_extend('force', {
    display_name = 'Conda',
    get_env_var_strategy = get_env_var_strategy.conda,
    binaries = DEFAULT_BINARIES,
  }, opts or {})
  return setmetatable(obj, Locator)
end

local function pick_binary(binaries)
  for _, bin in ipairs(binaries) do
    if vim.fn.executable(bin) == 1 then
      return bin
    end
  end
  return nil
end

function Locator:find(Job)
  return coroutine.wrap(function()
    local bin = pick_binary(self.binaries)
    if not bin then
      return
    end
    vim.system({ bin, 'info', '--json' }, {}, function(out)
      local ctx = { locator_name = self.name }
      if out.code ~= 0 then
        ctx.err = bin .. ' command error'
      else
        local ok, info = pcall(vim.json.decode, out.stdout)
        if ok then
          local envs = info.envs
          if envs then
            ctx.co = function()
              return self:_find(envs)
            end
          end
        else
          ctx.err = bin .. ' output is not json'
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
