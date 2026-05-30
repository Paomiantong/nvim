---@class InternalWhichPy.Ctx
---@field locator_name string
---@field wait? boolean
---@field err? string
---@field co? thread

local util = require('internal.whichpy.util')
local config = require('internal.whichpy.config').config

local SearchJob = {
  co = nil,
  _temp_envs = {},
  on_result = function(_) end,
  on_finish = function() end,
}

---@return "dead"|"normal"|"running"|"suspended"|nil
function SearchJob:status()
  return (self.co and coroutine.status(self.co)) or nil
end

function SearchJob:reset()
  self.co = nil
  self._temp_envs = {}
  self.on_result = function(_) end
  self.on_finish = function() end
end

local function ordered_locators()
  local locators = require('internal.whichpy.locator').locators
  local order = config.preferred_order or {}
  local seen, result = {}, {}
  for _, name in ipairs(order) do
    if locators[name] then
      result[#result + 1] = locators[name]
      seen[name] = true
    end
  end
  for name, loc in pairs(locators) do
    if not seen[name] then
      result[#result + 1] = loc
    end
  end
  return result
end

local function fill_version_from_pyvenv(info)
  if info.version then
    return true
  end
  local exe = info.executable or info.path
  if not exe then
    return false
  end
  local v = util.read_pyvenv_version(exe)
  if v then
    info.version = v
    return true
  end
  return false
end

local function fetch_versions(envs, on_each, done)
  local remaining = 0
  for _, info in ipairs(envs) do
    if not fill_version_from_pyvenv(info) then
      local exe = info.executable or info.path
      if exe then
        remaining = remaining + 1
        vim.system({ exe, '--version' }, { text = true }, function(obj)
          local out = ((obj.stdout or '') .. (obj.stderr or '')):gsub('%s+$', '')
          info.version = out:match('[Pp]ython%s+([%d%.]+)') or out
          if on_each then
            vim.schedule(function()
              on_each(info)
            end)
          end
          remaining = remaining - 1
          if remaining == 0 then
            vim.schedule(done)
          end
        end)
      end
    elseif on_each then
      on_each(info)
    end
  end
  if remaining == 0 then
    done()
  end
end

function SearchJob:start()
  if self.co ~= nil and self:status() ~= 'dead' then
    return
  end

  coroutine.wrap(function()
    self.co = coroutine.running()
    self._temp_envs = {}

    local wait_group = {}
    local sync_iters = {}

    -- Phase 1: prime every iterator so subprocess locators kick off vim.system
    -- before the main thread starts blocking on sync fs walks.
    for _, locator in ipairs(ordered_locators()) do
      ---@diagnostic disable-next-line: undefined-field
      local iter = locator:find(self)
      local ctx = iter()
      if ctx then
        if ctx.wait then
          wait_group[ctx.locator_name] = true
        else
          table.insert(self._temp_envs, ctx)
          self.on_result(ctx)
          sync_iters[#sync_iters + 1] = iter
        end
      end
    end

    -- Phase 2: drain sync iterators (subprocesses are already in flight).
    for _, iter in ipairs(sync_iters) do
      for ctx in iter do
        table.insert(self._temp_envs, ctx)
        self.on_result(ctx)
      end
    end

    -- Phase 3: collect async results.
    while not vim.tbl_isempty(wait_group) do
      ---@type InternalWhichPy.Ctx
      local ctx = coroutine.yield()
      if ctx.err ~= nil then
        vim.schedule(function()
          util.notify(ctx.err, vim.log.levels.ERROR)
        end)
      elseif ctx.co then
        for info in ctx.co() do
          table.insert(self._temp_envs, info)
          self.on_result(info)
        end
      end
      if not ctx.wait then
        wait_group[ctx.locator_name] = nil
      end
    end

    fetch_versions(self._temp_envs, self.on_result, function()
      require('internal.whichpy.envs').set_envs(self._temp_envs)
      self.on_finish()
      self:update_hook(nil, nil)
    end)
  end)()
end

function SearchJob:update_hook(on_result, on_finish)
  self.on_result = on_result or function(_) end
  self.on_finish = on_finish or function() end
end

---@param ctx InternalWhichPy.Ctx
function SearchJob:continue(ctx)
  coroutine.resume(self.co, ctx)
end

return SearchJob
