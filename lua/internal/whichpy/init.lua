local config = require('internal.whichpy.config')
local locator = require('internal.whichpy.locator')
local picker = require('internal.whichpy.picker')
local envs = require('internal.whichpy.envs')
local lsp = require('internal.whichpy.lsp')

local M = {}

function M.setup(opts)
  config.setup(opts or {})
  locator.setup()
  lsp.create_autocmd()
  envs.retrieve_cache()
  vim.api.nvim_create_user_command('WhichPySearch', function(args)
    picker:show({ force = args.bang })
  end, {
    nargs = '*',
    bang = true,
    desc = 'Search for Python interpreters (use ! to force a fresh scan)',
  })
  vim.api.nvim_create_user_command('WhichPyReset', function()
    envs.handle_reset()
  end, {
    nargs = 0,
    desc = 'Restore LSP / DAP / env to their pre-WhichPy state and clear this cwd cache',
  })
  vim.api.nvim_create_user_command('WhichPyClearCache', function()
    envs.clear_cache()
  end, {
    nargs = '*',
    desc = 'Clear all cached Python interpreter selections',
  })
end

return M
