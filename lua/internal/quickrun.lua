local api = vim.api
local quickRun = {}
local conf = require('internal.quickrunConfig')
local win, buf = -1, -1
local status = {
  running = false,
  jobId = -1,
}
local currentTask

local mappings = {
  q = 'close_win()', -- stop and close the runner
  i = 'insert_text()', -- input text
  ['<C-c>'] = 'stop()', -- stop current job
}

local function reset_status()
  status = {
    running = false,
    jobId = -1,
    startTime = 0,
    endTime = 0,
  }
end

local function foo() end

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
  currentTask.amountLines = currentTask.amountLines - 2 -- erase the blank lines
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
  local exceptCode = currentTask.jobs[currentTask.status].exceptCode
  if exceptCode == nil or exceptCode == code then
    currentTask.status = currentTask.status + 1
    quickRun.start(currentTask.jobs[currentTask.status])
  end
end

function quickRun.update_view(data)
  api.nvim_buf_set_option(buf, 'modifiable', true)
  api.nvim_buf_set_lines(buf, currentTask.amountLines, -1, false, data)
  currentTask.amountLines = currentTask.amountLines + #data
  api.nvim_win_set_cursor(win, { currentTask.amountLines, 1 })
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
    vim.keymap.set('n', key, '<cmd>lua require"internal.quickrun".' .. value .. '<cr>', {
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
  local jobOptions = { on_stdout = output, on_stderr = output, on_exit = exit }
  -- add environment option if it has one
  if job.env ~= nil then
    jobOptions.env = job.env
  end
  -- start the job and change status
  status.jobId = vim.fn.jobstart(job.cmd, jobOptions)
  -- notify the user that the job is running
  quickRun.update_view({ '[Job' .. status.jobId .. ' Running] ' .. table.concat(job.cmd, ' ') })
  if status.jobId > 0 then
    status.startTime = vim.fn.reltime()
    status.running = true
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
  currentTask = {
    jobs = task,
    amountLines = 0,
    status = 1,
  }
  quickRun.start(currentTask.jobs[currentTask.status])
end

function quickRun.test()
  local task = {
    { cmd = { 'gcc', 'test.c', '-o', 'test' }, exceptCode = 0 },
    { cmd = { './test' } },
    { cmd = { 'rm', 'test', '-rf' } },
  }
  quickRun.startTask(task)
end

return quickRun
