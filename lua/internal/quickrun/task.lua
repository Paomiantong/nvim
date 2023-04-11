Runner = require('runner')

---@class quickRun.Task
---@field jobs table
---@field phase number
---@field runner quickRun.Runner
local Task = {}

---@return quickRun.Task
function Task.new(jobs)
  return setmetatable({
    jobs = jobs,
    phase = 1,
  }, { __index = Task })
end

---@param runner quickRun.Runner
function Task:set_runner(runner)
  if runner == nil then
    return
  end

  self.runner = runner
end

function Task:next_phase(code)
  local exceptCode = self.jobs[self.phase].exceptCode
  if exceptCode == nil or exceptCode == code then
    self.phase = self.phase + 1
    self.runner:run(self)
  end
end

function Task:get_current_job()
  return self.jobs[self.phase]
end

function Task:start()
  self.runner:run(self)
end

return Task
