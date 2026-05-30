local SearchJob = require('internal.whichpy.search')
local config = require('internal.whichpy.config').config
local envs = require('internal.whichpy.envs')
local util = require('internal.whichpy.util')

local Picker = {}

function Picker:setup()
  return vim.tbl_deep_extend('force', { prompt = 'Select Python Interpreter' }, config.picker or {})
end

function Picker:_show(opts, items)
  vim.schedule(function()
    vim.ui.select(items, opts, function(choice)
      if choice ~= nil then
        envs.handle_select(choice)
      end
    end)
  end)
end

function Picker:_show_factor(opts)
  return function()
    self:_show(opts, envs.get_envs())
  end
end

---@param opts? { force?: boolean }
function Picker:show(opts)
  opts = opts or {}
  local select_opts = self:setup()
  local status = SearchJob:status()

  if opts.force then
    if status ~= nil and status ~= 'dead' then
      util.notify('Search in progress; reusing current run.')
      SearchJob:update_hook(nil, self:_show_factor(select_opts))
      return
    end
    envs.set_envs({})
    SearchJob:reset()
    status = nil
  end

  if status == nil then
    SearchJob:update_hook(nil, self:_show_factor(select_opts))
    SearchJob:start()
  elseif status ~= 'dead' then
    SearchJob:update_hook(nil, self:_show_factor(select_opts))
  else
    self:_show(select_opts, envs.get_envs())
  end
end

return Picker
