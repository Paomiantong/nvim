local util = require('internal.whichpy.util')
local uv = vim.uv
local get_interpreter_path = util.get_interpreter_path
local get_env_var_strategy = require('internal.whichpy.locator._common').get_env_var_strategy
local get_search_path_entries = require('internal.whichpy.locator._common').get_search_path_entries
local InterpreterInfo = require('internal.whichpy.locator').InterpreterInfo

local Locator = { name = 'global' }
Locator.__index = Locator

local function is_file(path)
  local st = uv.fs_stat(path)
  return st and st.type == 'file'
end

function Locator.new(opts)
  local obj = vim.tbl_deep_extend('force', {
    display_name = 'Global',
    get_env_var_strategy = get_env_var_strategy.guess,
  }, opts or {})
  return setmetatable(obj, Locator)
end

-- 只产出真正可执行的 python 解释器；去重；顺序按 PATH
function Locator:find()
  return coroutine.wrap(function()
    local dirs = get_search_path_entries()
    for _, dir in ipairs(dirs) do
      -- 先尝试默认 (python)，再尝试 python3
      local candidates = {
        get_interpreter_path(dir, 'root', false),
        get_interpreter_path(dir, 'root', true),
      }
      for _, path in ipairs(candidates) do
        if path and path ~= '' and is_file(path) then
          coroutine.yield(InterpreterInfo:new(self, path))
        end
      end
    end
  end)
end

return Locator
