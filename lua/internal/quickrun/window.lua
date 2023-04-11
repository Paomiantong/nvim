local log = require('log')
local api = vim.api

local M = {}

local instance = -1

local winOptions = {
  cursorline = true,
  wrap = false,
  spell = false,
  number = false,
  relativenumber = false,
  winfixheight = true,
  ['list'] = false,
}

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

function M.open()
  if not api.nvim_win_is_valid(instance) then
    log.debug('new runner window')
    instance = new()
  end
  return instance
end

function M.close()
  if api.nvim_win_is_valid(instance) then
    api.nvim_win_hide(instance)
  end
end

return M
