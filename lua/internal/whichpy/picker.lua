local SearchJob = require('internal.whichpy.search')
local config = require('internal.whichpy.config').config
local handle_select = require('internal.whichpy.envs').handle_select
local get_envs = require('internal.whichpy.envs').get_envs

local Picker = {}

function Picker:setup()
  return vim.tbl_deep_extend('force', { prompt = 'Select Python Interpreter' }, config.picker or {})
end

function Picker:_show(opts, envs)
  vim.schedule(function()
    vim.ui.select(envs, opts, function(choice)
      if choice ~= nil then
        handle_select(choice)
      end
    end)
  end)
end

function Picker:show()
  local opts = self:setup()

  if SearchJob:status() == nil then
    SearchJob:update_hook(nil, function()
      self:_show(opts, get_envs())
    end)
    SearchJob:start()
  elseif SearchJob:status() ~= 'dead' then
    SearchJob:update_hook(nil, function()
      self:_show(opts, get_envs())
    end)
  else
    self:_show(opts, get_envs())
  end
end

return Picker
