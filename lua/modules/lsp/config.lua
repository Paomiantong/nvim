local config = {}

function config.nvim_lsp()
  require('modules.lsp.lspconfig')
end

function config.mason()
  require('mason').setup()
end

function config.lspsaga()
  require('lspsaga').setup({
    lightbulb = {
      enable = true,
      enable_in_insert = true,
      sign = true,
      sign_priority = 40,
      virtual_text = true,
    },
    symbol_in_winbar = {
      enable = true,
      separator = '  ',
    },
  })
end

function config.nvim_cmp()
  require('modules.lsp.nvimcmp')
end

function config.lua_snip()
  local ls = require('luasnip')
  ls.config.set_config({
    history = false,
    updateevents = 'TextChanged,TextChangedI',
  })
  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_vscode').lazy_load({
    paths = { './snippets/' },
  })
end

function config.auto_pairs()
  require('nvim-autopairs').setup({})
  local status, cmp = pcall(require, 'cmp')
  if not status then
    vim.cmd([[packadd nvim-cmp]])
    cmp = require('cmp')
  end
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
end

function config.formatter()
  require('modules.lsp.formatter')
end

return config
