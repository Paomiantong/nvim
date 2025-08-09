-- Aggregator for python locators (async/coroutine based)
local config = require('internal.whichpy.config').config

---@class InternalWhichPy.Locator
---@field name string
---@field display_name string
---@field get_env_var_strategy fun(path:string):table
---@field find fun(self, Job): fun(...):unknown   -- returns coroutine (iterator)

local M = {}

M.locators = {}
M.last_selected = nil

-- runtime registry population based on config.locator
function M.setup()
  local locator_cfg = config.locator or {}
  for name, opts in pairs(locator_cfg) do
    if opts.enable ~= false then
      local ok, mod = pcall(require, 'internal.whichpy.locator.' .. name)
      if ok and mod.new then
        M.locators[name] = mod.new(opts)
      end
    end
  end
end

function M.get_locator(locator_name)
  local ok, locator = pcall(require, 'internal.whichpy.locator.' .. locator_name)
  if not ok then
    return
  end
  local opts = config.locator[locator_name] or {}
  opts.enable = nil
  return locator.new(opts)
end

---@class InternalWhichPy.InterpreterInfo
---@field locator_name string
---@field path string
---@field _locator InternalWhichPy.Locator
---@field env_var fun(self:InternalWhichPy.InterpreterInfo):table
local InterpreterInfo = {}
InterpreterInfo.__index = InterpreterInfo

function InterpreterInfo:new(locator, path)
  return setmetatable({
    locator_name = locator.name,
    path = vim.fn.fnamemodify(path, ':p'),
    _locator = locator,
  }, self)
end

function InterpreterInfo:__tostring()
  local prefix = self._locator.display_name or self.locator_name
  local env_var = self:env_var()
  if env_var.val then
    prefix = prefix .. ': ' .. vim.fs.basename(env_var.val)
  end
  return string.format('(%s) %s', prefix, vim.fn.fnamemodify(self.path, ':p:~:.'))
end

function InterpreterInfo:env_var()
  if self._locator and self._locator.get_env_var_strategy then
    return self._locator.get_env_var_strategy(self.path)
  end
  return {}
end

M.InterpreterInfo = InterpreterInfo

return M
