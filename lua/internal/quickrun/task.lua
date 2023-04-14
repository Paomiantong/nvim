Runner = require('internal.quickrun.runner')

---@class quickRun.Task
---@field name string
---@field jobs table
---@field phase number
---@field runner quickRun.Runner
local Task = {}

---new a `task`
---@param jobs table the `jobs` which a task consisted of
---@return quickRun.Task task a new `task`
function Task.new(jobs)
  return setmetatable({
    jobs = jobs,
    phase = 1,
  }, { __index = Task })
end

---set `runner`
---@param runner quickRun.Runner
function Task:set_runner(runner)
  if runner == nil then
    return
  end

  self.runner = runner
end

---next phase
---@param code number the exit code of previous `job`
function Task:next_phase(code)
  local exceptCode = self.jobs[self.phase].exceptCode
  if exceptCode == nil or exceptCode == code then
    self.phase = self.phase + 1
    self.runner:run(self)
  end
end

---get current `job`
---@return table
function Task:get_current_job()
  return self.jobs[self.phase]
end

---start the `task`
function Task:start()
  self.runner:run(self)
end

---stop the `task`
function Task:stop()
  self.runner:stop()
end

---reset the `task`
function Task:reset()
  self.phase = 1
end

return Task
