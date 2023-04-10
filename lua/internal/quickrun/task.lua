Runner = require('runner')

---@class quickRun.Task
---@field jobs table
---@field phase number
---@field runner quickRun.Runner
local Task = {}

---@return quickRun.Task
function Task.new(jobs)
  local o = setmetatable({
    jobs = jobs,
    phase = 1,
    runner = Runner.new(),
  }, { __index = Task })
  return o
end

function Task:nextPhase(code)
  local exceptCode = self.jobs[self.phase].exceptCode
  if exceptCode == nil or exceptCode == code then
    self.phase = self.phase + 1
    self.runner.run(self.jobs[self.phase], self.nextPhase)
  end
end

function Task:start()
  self.runner.run(self.jobs[self.phase], self.nextPhase)
end

return Task
