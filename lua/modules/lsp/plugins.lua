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
      keyword = {
        range = 'full',
      },
      list = {
        selection = {
          preselect = false,
        },
      },
    },
    keymap = {
      preset = 'default',
      ['<M-o>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
      ['<Enter>'] = { 'accept', 'fallback' },
    },
    signature = {
      enabled = true,
      window = {
        show_documentation = true,
      }
    },
    cmdline = {
      keymap = {
        ['<Tab>'] = { 'show', 'accept' },
        ['<Enter>'] = { 'select_and_accept', 'fallback' },
      },
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        cmdline = {
          min_keyword_length = function(ctx)
            -- when typing a command, only show when the keyword is 3 characters or longer
            if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then
              return 3
            end
            return 0
          end,
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
