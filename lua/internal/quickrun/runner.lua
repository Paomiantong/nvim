local Buffer = require('buffer')

---@class quickRun.Runner
---@field buffer quickRun.Buffer
---@field jobId number
---@field running boolean
---@field startTime number
---@field endTime  number
local Runner = {}

---@param b quickRun.Buffer
---@return quickRun.Runner
function Runner.new(b)
  b = b or Buffer.new()
  local o = {
    buffer = b,
    running = false,
    jobId = -1,
    startTime = 0,
    endTime = 0,
  }
  setmetatable(o, Runner)
  return o
end

function Runner:run(job, on_exit)
  if job == nil then
    return
  end

  local function output(data)
    self.buffer.render(data)
  end

  local function exit(code)
    -- change status
    self.endTime = vim.fn.reltime(self.startTime)
    self.running = false
    self.buffer.amountLines = self.buffer.amountLines - 2 -- erase the blank lines
    -- notify the user that the job is done
    self.buffer.render({
      '[Job'
        .. self.jobId
        .. ' Done] exited with code = '
        .. code
        .. ' in'
        .. vim.fn.reltimestr(self.endTime)
        .. ' seconds',
      '',
    })
    -- start the next job
    on_exit(code)
  end

  -- set the job options
  local jobCmd = job[1] ~= nil and job[1] or job.cmd
  local jobOptions = {
    on_stdout = function(j, d)
      if self.jobId ~= j then
        return
      end
      output(d)
    end,
    on_stderr = function(j, d)
      if self.jobId ~= j then
        return
      end
      output(d)
    end,
    on_exit = function(j, d)
      if self.jobId ~= j then
        return
      end
      exit(d)
    end,
  }
  local cmdString = type(jobCmd) == 'table' and table.concat(jobCmd, ' ') or jobCmd
  -- add environment option if it has one
  if job.env ~= nil then
    jobOptions.env = job.env
  end
  -- start the job and change status
  local ok, result = pcall(vim.fn.jobstart, jobCmd, jobOptions)
  if not ok then
    vim.notify(result, vim.log.levels.ERROR, { title = 'quickRun' })
    return
  end
  self.jobId = result
  -- notify the user that the job is running
  self.buffer.render({ '[Job' .. self.jobId .. ' Running] ' .. cmdString })
  if result > 0 then
    self.startTime = vim.fn.reltime()
    self.running = true
  else
    vim.notify('run' .. cmdString .. 'failed', vim.log.levels.WARN, { title = 'quickRun' })
  end
end

return Runner
