-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT
local package = require('core.pack').package
local conf = require('modules.ui.config')

-- the colorscheme should be available when starting Neovim
-- package({
--   'folke/tokyonight.nvim',
--   config = conf.tokyonight,
--   -- make sure we load this during startup if it is your main colorscheme
--   lazy = false,
--   -- make sure to load this before all the other start plugins
--   priority = 1000,
-- })
package({
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    vim.cmd.colorscheme('catppuccin-frappe')
  end,
})

-- package({
--     'glepnir/dashboard-nvim',
--     config = conf.dashboard,
--     event = 'VimEnter'
-- })

package({
  'rebelot/heirline.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'linrongbin16/lsp-progress.nvim',
    config = function()
      require('modules.ui.heirline.lspprogress')
    end,
  },
  init = function()
    vim.keymap.set('n', '<leader>tt', function()
      vim.o.showtabline = vim.o.showtabline == 0 and 2 or 0
    end, {
      desc = 'Toggle tabline',
    })
  end,
  config = function()
    vim.opt.cmdheight = 0
    require('heirline').setup({
      statusline = require('modules.ui.heirline.statusline'),
    })
  end,
})

package({
  'akinsho/bufferline.nvim',
  config = conf.nvim_bufferline,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- version = 'v3.*',
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
