local log = require('internal.quickrun.log')
local Buffer = require('internal.quickrun.buffer')
local Window = require('internal.quickrun.window')

local mappings = {
  --   q = 'close_win', -- stop and close the runner
  i = 'insert_text', -- input text
  I = 'insert_text', -- input text
  a = 'insert_text', -- input text
  A = 'insert_text', -- input text
  o = 'insert_text', -- input text
  O = 'insert_text', -- input text
  ['<C-c>'] = 'stop', -- stop current job
  r = 'restart', -- restart the task
}

---* @example
---<pre>
---local task = task_generator.generate_run_singlefile_task()
---local runner = runner_manager.get_runner()
---runner:start(task)
---</pre>
---@class quickRun.Runner
---@field buffer quickRun.Buffer
---@field jobId number
---@field running boolean
---@field startTime number
---@field endTime  number
---@field current_task quickRun.Task
local Runner = {}

---new a `runner`
---@param b? quickRun.Buffer the `buffer` which the runner output data
---@return quickRun.Runner runner a new `runner`
function Runner.new(b)
  b = b or Buffer.new()

  local o = setmetatable({
    running = false,
    jobId = -1,
    startTime = 0,
    endTime = 0,
  }, { __index = Runner })

  o:_bind_buffer(b)
  return o
end

---run
function Runner:run()
  local job = self.current_task:get_current_job()
  if job == nil then
    return
  end

  local function exit(code)
    -- change status
    self.endTime = vim.fn.reltime(self.startTime)
    self.running = false
    self.buffer.amountLines = self.buffer.amountLines - 2 -- erase the blank lines
    -- notify the user that the job is done
    self.buffer:render({
      '[Job'
        .. self.jobId
        .. ' Done] exited with code = '
        .. code
        .. ' in'
        .. vim.fn.reltimestr(self.endTime)
        .. ' seconds',
      '',
    }, code == 0 and 'Function' or 'Error')
    -- start the next job
    if self.current_task:next_phase(code) then
      self:run()
    end
  end

  -- set the job options
  local cmd = job[1] ~= nil and job[1] or job.cmd
  local opts = job[2] ~= nil and job[2] or job.opts
  local job_opts = vim.tbl_extend('force', opts or {}, {
    on_stdout = function(j, d)
      if self.jobId ~= j then
        return
      end
      self.buffer:render(d)
    end,
    on_stderr = function(j, d)
      if self.jobId ~= j then
        return
      end
      self.buffer:render(d, 'Error')
    end,
    on_exit = function(j, d)
      if self.jobId ~= j then
        return
      end
      exit(d)
    end,
  })
  local name = type(cmd) == 'table' and table.concat(cmd, ' ') or cmd

  -- start the job and change status
  local ok, result = pcall(vim.fn.jobstart, cmd, job_opts)
  if not ok then
    log.error(result)
    return
  end
  self.jobId = result

  -- notify the user that the job is running
  self.buffer:render({ '[Job' .. self.jobId .. ' Running] ' .. name }, 'Function')
  if result > 0 then
    self.startTime = vim.fn.reltime()
    self.running = true
  else
    log.warn('run' .. name .. 'failed')
  end
end

---start the `runner`
---@param task quickRun.Task the `task` to be excuted
function Runner:start(task)
  if task == nil then
    return
  end
  self.current_task = task
  self.buffer:set_variable('task_name', self.current_task.name)
  self:run()
end

---stop the `runner`
function Runner:stop()
  if self.running == true then
    vim.fn.jobstop(self.jobId)
    self.running = false
  end
end

---reset the `runner`
function Runner:reset()
  self:stop()
  local previous_buffer = self.buffer
  self:_bind_buffer(Buffer.new())
  self.buffer:set_variable('task_name', self.current_task.name)
  if previous_buffer.attached then
    Window.attachBuffer(self.buffer)
  end
  previous_buffer:delete()
end

---restart the `runner`
function Runner:restart()
  self:reset()
  self.current_task:reset()
  self:run()
end

---input to the `job`
function Runner:insert_text()
  if self.running == false then
    return
  end

  vim.fn.inputsave()
  local data = vim.fn.input('input >')
  self.buffer:render({ data }, 'String')
  if #data > 0 then
    vim.fn.chansend(self.jobId, data .. '\n\n')
  end
  vim.fn.inputrestore()
end

---@private
---bind `buffer`
---@param b quickRun.Buffer the `buffer` which the runner output data
function Runner:_bind_buffer(b)
  self.buffer = b
  for key, value in pairs(mappings) do
    vim.keymap.set('n', key, function()
      self[value](self)
    end, {
      nowait = true,
      noremap = true,
      silent = true,
      buffer = b.bufnr,
    })
  end
  vim.keymap.set('n', 'q', '<CMD>QRWindowToggle<CR>', {
    nowait = true,
    noremap = true,
    silent = true,
    buffer = b.bufnr,
  })
  --   vim.keymap.set('n', 'p', '"+p', {
  --     nowait = true,
  --     noremap = true,
  --     silent = true,
  --     buffer = b.bufnr,
  --   })
end
return Runner
