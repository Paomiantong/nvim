-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT

local package = require('core.pack').package
local conf = require('modules.ui.config')

-- the colorscheme should be available when starting Neovim
package({
  'folke/tokyonight.nvim',
  config = conf.tokyonight,
  -- make sure we load this during startup if it is your main colorscheme
  lazy = false,
  -- make sure to load this before all the other start plugins
  priority = 1000,
})

-- package({
--     'projekt0n/github-nvim-theme',
--     tag = 'v0.0.7',
--     -- or                            branch = '0.0.x'
--     config = function()
--         require('github-theme').setup({
--             theme_style = "light_default",
--             -- ...
--         })
--     end,
--     -- make sure we load this during startup if it is your main colorscheme
--     lazy = false,
--     -- make sure to load this before all the other start plugins
--     priority = 1000
-- })

package({ 'glepnir/dashboard-nvim', config = conf.dashboard, event = 'VimEnter' })

package({
  'glepnir/galaxyline.nvim',
  config = conf.galaxyline,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
})

package({
  'kyazdani42/nvim-tree.lua',
  cmd = 'NvimTreeToggle',
  config = conf.nvim_tree,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
})

package({
  'akinsho/bufferline.nvim',
  config = conf.nvim_bufferline,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  version = 'v3.*',
})

local enable_indent_filetype = {
  'go',
  'lua',
  'sh',
  'rust',
  'cpp',
  'c',
  'typescript',
  'typescriptreact',
  'javascript',
  'json',
  'python',
}

package({
  'lukas-reineke/indent-blankline.nvim',
  ft = enable_indent_filetype,
  config = conf.indent_blankline,
})

package({
  'lewis6991/gitsigns.nvim',
  event = { 'BufRead', 'BufNewFile' },
  config = conf.gitsigns,
})
