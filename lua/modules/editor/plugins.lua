-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT

local package = require('core.pack').package
local conf = require('modules.editor.config')

package({
  'kyazdani42/nvim-tree.lua',
  cmd = 'NvimTreeToggle',
  config = conf.nvim_tree,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
})

package({
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  config = conf.telescope,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-fzy-native.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
  },
})

package({
  'nvim-treesitter/nvim-treesitter',
  event = 'BufRead',
  run = ':TSUpdate',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  config = conf.nvim_treesitter,
})

package({
  'ii14/emmylua-nvim',
  ft = 'lua',
})

package({
  'rcarriga/nvim-notify',
  config = function()
    vim.notify = require('notify')
  end,
  priority = 1000,
})

package({
  'folke/noice.nvim',
  config = conf.noice,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
})
