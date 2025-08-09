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
    picker:show()
  end, {
    nargs = '*',
    desc = 'Search for Python interpreters using WhichPy locators',
  })
end

return M
