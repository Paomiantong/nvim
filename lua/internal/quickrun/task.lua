Runner = require('internal.quickrun.runner')

---@class quickRun.Task
---@field name string
---@field jobs table
---@field phase number
local Task = {}

---new a `task`
---@param jobs table the `jobs` which a task consisted of
---@param name? string name of the task
---@return quickRun.Task task a new `task`
function Task.new(jobs, name)
  return setmetatable({
    name = name or 'Task',
    jobs = jobs,
    phase = 1,
  }, { __index = Task })
end

---next phase
---@param code number the exit code of previous `job`
function Task:next_phase(code)
  if self.phase >= #self.jobs then
    return false
  end
  local exceptCode = self.jobs[self.phase].exceptCode
  if exceptCode == nil or exceptCode == code then
    self.phase = self.phase + 1
    return true
  end
  return false
end

---get current `job`
---@return table
function Task:get_current_job()
  return self.jobs[self.phase]
end

---reset the `task`
function Task:reset()
  self.phase = 1
end

return Task
