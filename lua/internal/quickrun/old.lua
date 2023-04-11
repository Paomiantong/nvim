local api = vim.api
local create_user_command = api.nvim_create_user_command --- @type function

local quickRun = {}
-- local conf = require('internal.quickrunConfig')
local win, buf = -1, -1
local status = {
  running = false,
  jobId = -1,
}
local currentTaskStatus

local mappings = {
  q = 'close_win', -- stop and close the runner
  i = 'insert_text', -- input text
  ['<C-c>'] = 'stop', -- stop current job
}

local function reset_status() --- @type function
  status = {
    running = false,
    jobId = -1,
    startTime = 0,
    endTime = 0,
  }
end

local function input(id, data)
  vim.fn.chansend(id, data)
end

local function output(id, data)
  if id ~= status.jobId then
    return
  end
  quickRun.update_view(data)
end

local function exit(id, code)
  if id ~= status.jobId then
    return
  end
  -- change status
  status.endTime = vim.fn.reltime(status.startTime)
  status.exitedCode = code
  status.running = false
  currentTaskStatus.amountLines = currentTaskStatus.amountLines - 2 -- erase the blank lines
  -- notify the user that the job is done
  quickRun.update_view({
    '[Job'
      .. status.jobId
      .. ' Done] exited with code = '
      .. code
      .. ' in'
      .. vim.fn.reltimestr(status.endTime)
      .. ' seconds',
    '',
  })
  -- start the next job
  local exceptCode = currentTaskStatus.jobs[currentTaskStatus.phase].exceptCode
  if exceptCode == nil or exceptCode == code then
    currentTaskStatus.phase = currentTaskStatus.phase + 1
    quickRun.start(currentTaskStatus.jobs[currentTaskStatus.phase])
  end
end

function quickRun.update_view(data)
  api.nvim_buf_set_option(buf, 'modifiable', true)
  api.nvim_buf_set_lines(buf, currentTaskStatus.amountLines, -1, false, data)
  currentTaskStatus.amountLines = currentTaskStatus.amountLines + #data
  api.nvim_win_set_cursor(win, { currentTaskStatus.amountLines, 1 })
  api.nvim_buf_set_option(buf, 'modifiable', false)
end

function quickRun.insert_text()
  if status.running == false then
    return
  end

  vim.fn.inputsave()
  local data = vim.fn.input('input >')
  quickRun.update_view({ data })
  if #data > 0 then
    input(status.jobId, data .. '\n')
  end
  vim.fn.inputrestore()
end

local bufOptions = {
  buftype = 'nofile',
  swapfile = false,
  filetype = 'runner',
  bufhidden = 'wipe',
  buflisted = false,
  modifiable = false,
}

local winOptions = {
  cursorline = true,
  wrap = false,
  spell = false,
  number = false,
  relativenumber = false,
  winfixheight = true,
  ['list'] = false,
}

function quickRun.create_win()
  if api.nvim_win_is_valid(win) then
    return
  end
  -- open the runner window and save the id of buffer and window
  api.nvim_command('botright split Runner')
  win = api.nvim_get_current_win()
  buf = api.nvim_get_current_buf()

  api.nvim_buf_set_name(buf, 'Runner#' .. buf)
  -- set buffer options
  for option, value in pairs(bufOptions) do
    api.nvim_buf_set_option(buf, option, value)
  end
  -- set window options
  for option, value in pairs(winOptions) do
    api.nvim_win_set_option(win, option, value)
  end
  -- register hotkey
  for key, value in pairs(mappings) do
    vim.keymap.set('n', key, function()
      quickRun[value]()
    end, {
      nowait = true,
      noremap = true,
      silent = true,
      buffer = true,
    })
  end
end

function quickRun.close_win()
  if api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
  end
  quickRun.stop()
end

function quickRun.start(job)
  if job == nil then
    return
  end
  -- reset job status
  reset_status()
  -- set the job options
  local jobCmd = job[1] ~= nil and job[1] or job.cmd
  local jobOptions = { on_stdout = output, on_stderr = output, on_exit = exit }
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
  status.jobId = result
  -- notify the user that the job is running
  quickRun.update_view({ '[Job' .. status.jobId .. ' Running] ' .. cmdString })
  if status.jobId > 0 then
    status.startTime = vim.fn.reltime()
    status.running = true
  else
    vim.notify('run' .. cmdString .. 'failed', vim.log.levels.WARN, { title = 'quickRun' })
  end
end

function quickRun.stop()
  if status.running == true then
    vim.fn.jobstop(status.jobId)
  end
end

function quickRun.get_current_job_status()
  return status
end

function quickRun.startTask(task)
  quickRun.create_win()
  currentTaskStatus = {
    jobs = task,
    amountLines = 0,
    phase = 1,
  }
  quickRun.start(currentTaskStatus.jobs[currentTaskStatus.phase])
end

local ok, _ = pcall(vim.api.nvim_del_user_command, 'QTest')
if not ok then
  vim.notify('reload failed', vim.log.levels.ERROR, { title = 'quickRun' })
end

create_user_command('QTest', function(tbl)
  local task = {
    { { 'gcc', 'test.c', '-o', 'test' }, exceptCode = 0 },
    { { './test.exe' } },
    { 'dir' },
  }
  quickRun.startTask(task)
end, {})

return quickRun
