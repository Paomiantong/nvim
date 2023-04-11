local api = vim.api

local Window = require('window')
local Buffer = require('buffer')
local Runner = require('runner')
local Task = require('task')

local win = Window.open()
local buf = Buffer.new()
local runner = Runner.new(buf)
local task = Task.new({
  { { 'gcc', 'test.c', '-o', 'test' }, { cwd = './test' }, exceptCode = 0 },
  { { './test/test' }, { cwd = './test' } },
  { 'dir' },
})

task:set_runner(runner)
api.nvim_win_set_buf(win, buf.bufnr)
task:start()
-- vim.defer_fn(function()
--   Window.close()
--   vim.defer_fn(function()
--     win = Window.open()
--     api.nvim_win_set_buf(win, buf.bufnr)
--   end, 2000)
-- end, 2000)
