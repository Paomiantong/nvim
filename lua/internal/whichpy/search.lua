---@class InternalWhichPy.Ctx
---@field locator_name string
---@field wait? boolean
---@field err? string
---@field co? thread

local util = require('internal.whichpy.util')
local locators = require('internal.whichpy.locator').locators

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

function SearchJob:start()
  if self.co ~= nil and self.status(self) ~= 'dead' then
    return
  end

  coroutine.wrap(function()
    self.co = coroutine.running()
    self._temp_envs = {}

    local wait_group = {}
    for _, locator in pairs(locators) do
      ---@param ctx InternalWhichPy.Ctx|InternalWhichPy.InterpreterInfo
      ---@diagnostic disable-next-line: undefined-field
      for ctx in locator:find(self) do
        if ctx.wait then
          wait_group[ctx.locator_name] = true
        else
          table.insert(self._temp_envs, ctx)
          if self.on_result then
            self.on_result(ctx)
          end
        end
      end
    end

    while not vim.tbl_isempty(wait_group) do
      ---@type InternalWhichPy.Ctx
      local ctx = coroutine.yield()
      if ctx.err ~= nil then
        vim.schedule(function()
          util.notify(ctx.err, { level = vim.log.levels.ERROR })
        end)
      elseif ctx.co then
        for info in ctx.co() do
          table.insert(self._temp_envs, info)
          -- util.notify(vim.inspect(info), { level = vim.log.levels.INFO })
          if self.on_result then
            self.on_result(info)
          end
        end
      end
      if not ctx.wait then
        wait_group[ctx.locator_name] = nil
      end
    end

    -- 新增: 异步获取版本信息
    local function fetch_versions(envs, done)
      local remaining = 0
      for _, info in ipairs(envs) do
        -- 约定: 尝试 executable / path 字段
        local exe = info.executable or info.path
        if exe and not info.version then
          remaining = remaining + 1
          vim.system({ exe, '--version' }, { text = true }, function(obj)
            local out = ((obj.stdout or '') .. (obj.stderr or '')):gsub('%s+$', '')
            -- 常见输出: Python 3.11.4
            local ver = out:match('[Pp]ython%s+([%d%.]+)') or out
            info.version = ver
            -- 回调更新（可选, 让 UI 刷新版本）
            if self.on_result then
              vim.schedule(function()
                self.on_result(info)
              end)
            end
            remaining = remaining - 1
            if remaining == 0 then
              vim.schedule(done)
            end
          end)
        end
      end
      if remaining == 0 then
        done()
      end
    end

    fetch_versions(self._temp_envs, function()
      require('internal.whichpy.envs').set_envs(self._temp_envs)
      self.on_finish()
      self.update_hook(self, nil, nil)
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
