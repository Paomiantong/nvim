-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT
local package = require('core.pack').package
local conf = require('modules.lsp.config')

package({
  'williamboman/mason.nvim',
  config = conf.mason,
})

package({
  'nvimdev/lspsaga.nvim',
  event = 'VeryLazy',
  config = function()
    require('lspsaga').setup({
      ui = {
        code_action = '',
      },
      lightbulb = {
        enable = false,
        virtual_text = false,
      },
    })
  end,
})

package({
  'mhartington/formatter.nvim',
  config = conf.formatter,
  cmd = 'Format',
  ft = fts,
})

package({
  'saghen/blink.cmp',
  event = { 'BufReadPost', 'BufNewFile' },
  version = '1.*',
  opts = {
    completion = {
      documentation = {
        auto_show = true,
      },
    },
    keymap = {
      preset = 'default',
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<Enter>'] = { 'accept', 'fallback' },
    },
    signature = {
      enabled = true,
    },
    cmdline = {
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        snippets = {
          score_offset = 1000,
        },
      },
    },
  },
})

package({
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
})

package({
  'L3MON4D3/LuaSnip',
  event = 'InsertCharPre',
  config = conf.lua_snip,
})

package({
  {
    'altermo/ultimate-autopair.nvim',
    event = { 'InsertEnter' },
    branch = 'v0.6', -- recommended as each new version will have breaking changes
    opts = conf.auto_pairs,
  },
})

package({
  dir = vim.fn.stdpath('config') .. '/lua/internal/whichpy',
  event = { 'LspAttach' },
  config = function()
    require('internal.whichpy').setup({
      update_path_env = true, -- whether to adjust PATH when selecting interpreter
    })
  end,
})
