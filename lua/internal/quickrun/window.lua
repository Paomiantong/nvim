local log = require('internal.quickrun.log')
local Buffer = require('internal.quickrun.buffer')
local api = vim.api

local M = {}

local default_buffer = Buffer.new()
M.buf = default_buffer
default_buffer:render({ 'Hello World!' }, 'String')

default_buffer:set_variable('task_name', 'Hi Quickrun')

local instance = -1

local function instance_is_valid()
  return api.nvim_win_is_valid(instance)
end

local winOptions = {
  cursorline = true,
  wrap = false,
  spell = false,
  number = false,
  relativenumber = false,
  winfixheight = true,
  ['list'] = false,
}

---new a runner `window`
---@return number
local function new()
  -- open the runner window and save the id of buffer and window
  api.nvim_command('botright split')
  local win = api.nvim_get_current_win()
  -- set window options
  for option, value in pairs(winOptions) do
    api.nvim_win_set_option(win, option, value)
  end
  return win
end

---open the runner `window`
---@return number id the runner window `id`
function M.open()
  if not instance_is_valid() then
    log.info('new runner window')
    instance = new()
  end
  return instance
end

---close the runner `window`
function M.close()
  if instance_is_valid() then
    api.nvim_win_hide(instance)
  end
end

---toggle the runner `window`
---@param buf? quickRun.Buffer the `buffer` need to be attached (`default`: previous buffer or default buffer)
function M.toggle(buf)
  if instance_is_valid() then
    M.close()
  else
    M.open()
    M.attachBuffer(buf)
  end
end

---attach `buffer`
---@param buf? quickRun.Buffer the `buffer` need to be attached
function M.attachBuffer(buf)
  buf = buf or M.buf
  --- attach new buf and detach previous buffer
  if buf ~= M.buf then
    M.buf:on_detach()
    M.buf = buf
  end

  if not instance_is_valid() then
    return
  end
  --- if the buf need to be attached is invalid then attach the default buffer
  if not M.buf:is_valid() then
    M.buf = default_buffer
  end
  M.buf:on_attach(instance)
  api.nvim_win_set_buf(instance, M.buf.bufnr)
end

return M
