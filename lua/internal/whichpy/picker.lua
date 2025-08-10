local SearchJob = require('internal.whichpy.search')
local config = require('internal.whichpy.config').config
local handle_select = require('internal.whichpy.envs').handle_select
local get_envs = require('internal.whichpy.envs').get_envs

local Picker = {}

function Picker:setup()
  return vim.tbl_deep_extend('force', { prompt = 'Select Python Interpreter' }, config.picker or {})
end

function Picker:_show(opts, envs)
  -- print('Picker:_show', vim.inspect(opts), vim.inspect(envs))
  vim.schedule(function()
    vim.ui.select(envs, opts, function(choice)
      if choice ~= nil then
        handle_select(choice)
      end
    end)
  end)
end

function Picker:_show_factor(opts)
  return function()
    self:_show(opts, get_envs())
  end
end

function Picker:show()
  local opts = self:setup()
  -- self:_show_factor(opts)
  if SearchJob:status() == nil then
    SearchJob:update_hook(nil, self:_show_factor(opts))
    SearchJob:start()
  elseif SearchJob:status() ~= 'dead' then
    SearchJob:update_hook(nil, self:_show_factor(opts))
  else
    self:_show(opts, get_envs())
  end
end

return Picker
