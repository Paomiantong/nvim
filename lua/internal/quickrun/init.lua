local api = vim.api

local Window = require('internal.quickrun.window')
local runner_manager = require('internal.quickrun.runner_manager')
local task_generator = require('internal.quickrun.task_generator')
-- local log = require('internal.quickrun.log')

api.nvim_create_user_command('QRWindowToggle', function()
  Window.toggle()
end, {})
vim.keymap.set('n', '<Leader>r', '<CMD>QRWindowToggle<CR>', {
  nowait = true,
  noremap = true,
  silent = true,
})

api.nvim_create_user_command('QRunSingleFile', function()
  local task = task_generator.generate_run_singlefile_task()
  if task == nil then
    return
  end
  task.name = vim.fn.expand('%:t')
  local runner = runner_manager.get_runner()
  Window.open()
  Window.attachBuffer(runner.buffer)
  runner:start(task)
end, {})
vim.keymap.set('n', '<space>qr', '<CMD>QRunSingleFile<CR>', {
  nowait = true,
  noremap = true,
  silent = true,
})
