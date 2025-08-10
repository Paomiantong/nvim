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

-- package({
--     'nvim-telescope/telescope.nvim',
--     cmd = 'Telescope',
--     config = conf.telescope,
--     dependencies = {'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzy-native.nvim',
--                     'nvim-telescope/telescope-file-browser.nvim'}
-- })

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
  dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
})

package({
  'folke/snacks.nvim',
  lazy = false,
  config = require('modules.editor.snacks').config,
})

package({
  'folke/which-key.nvim',
  event = 'VimEnter',
  config = conf.wk,
})

package({
  'echasnovski/mini.files',
  version = false,
  config = conf.minifiles,
})

package({
  'stevearc/overseer.nvim',
  event = 'VeryLazy',
  cmd = {
    'OverseerQuickAction',
    'OverseerTaskAction',
    'OverseerToggle',
    'OverseerOpen',
  },
  keys = {
    { '<leader>rl', '<cmd>OverseerRun<cr>',         desc = 'Overseer run templates' },
    { '<leader>rr', '<cmd>OverseerRestartLast<cr>', desc = 'Overseer restart last command' },
    { '<leader>rt', '<cmd>OverseerToggle<cr>',      desc = 'Overseer toggle task list' },
    { '<leader>ra', '<cmd>OverseerToggle<cr>',      desc = 'Overseer toggle task list' },
  },
  config = function()
    require('modules.editor.overseer')
  end,
})

package({
  'folke/flash.nvim',
  event = 'VeryLazy',
  ---@type Flash.Config
  opts = {
    modes = {
      char = {
        enabled = false,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
    { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
    { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
    { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
  },
})
