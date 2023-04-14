local log = require('internal.quickrun.log')
local Runner = require('internal.quickrun.runner')

local M = {}

---@type quickRun.Runner[]
M.runner_list = {}

---get a idle `runner`
---@return quickRun.Runner runner a idle `runner`
function M.get_runner()
  for _, runner in ipairs(M.runner_list) do
    if not runner.running then
      runner:reset()
      return runner
    end
  end

  log.info('new runner')
  local r = Runner.new()
  table.insert(M.runner_list, r)
  return r
end

---get a idle `runner`
---@return quickRun.Runner runner a idle `runner`
function M.get_runner_index()
  for _, runner in ipairs(M.runner_list) do
    if not runner.running then
      runner:reset()
      return runner
    end
  end

  log.info('new runner')
  local r = Runner.new()
  table.insert(M.runner_list, r)
  return r
end

return M
