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
---@field version? string
---@field _locator InternalWhichPy.Locator
---@field env_var fun(self:InternalWhichPy.InterpreterInfo):table
local InterpreterInfo = {}
InterpreterInfo.__index = InterpreterInfo

function InterpreterInfo:new(locator, path, version)
  return setmetatable({
    locator_name = locator.name,
    path = vim.fn.fnamemodify(path, ':p'),
    version = version,
    _locator = locator,
  }, self)
end

function InterpreterInfo:__tostring()
  local prefix = self.version or self.locator_name
  local env_var = self:env_var()
  if env_var.val then
    prefix = vim.fs.basename(env_var.val) .. ': ' .. prefix
  end
  return string.format('(%s) %s', prefix, vim.fn.fnamemodify(self.path, ':p:~:.'))
end

function InterpreterInfo:env_name()
  local version = self.version or self.locator_name
  local env_var = self:env_var().val and vim.fs.basename(self:env_var().val) or self.locator_name
  return string.format('%s(%s)', env_var, version)
end

function InterpreterInfo:env_var()
  if self._env_var then
    return self._env_var
  end
  if self._locator and self._locator.get_env_var_strategy then
    self._env_var = self._locator.get_env_var_strategy(self.path)
    return self._env_var
  end
  return {}
end

M.InterpreterInfo = InterpreterInfo

return M
