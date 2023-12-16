-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT

local package = require('core.pack').package
local conf = require('modules.lsp.config')
local fts = {
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
  'css',
  'html',
}

if LCOALCONF and LCOALCONF.lsp_fts then
    for _, v in pairs(LCOALCONF.lsp_fts) do
        table.insert(fts,v)
      end
end

package({
  'neovim/nvim-lspconfig',
  -- used filetype to lazyload lsp
  -- config your language filetype in here
  ft = fts,
  config = conf.nvim_lsp,
  dependencies = {
    { 'williamboman/mason.nvim', config = conf.mason },
    {
      'glepnir/lspsaga.nvim',
      event = 'LspAttach',
      cmd = 'Lspsaga term_toggle',
      config = conf.lspsaga,
      dependencies = {
        { 'nvim-tree/nvim-web-devicons' },
        --Please make sure you install markdown and markdown_inline parser
        { 'nvim-treesitter/nvim-treesitter' },
      },
    },
  },
})

-- package({
--     'glepnir/easyformat.nvim',
--     ft = enable_indent_filetype,
--     config = conf.easyformat,
-- })

package({
  'mhartington/formatter.nvim',
  config = conf.formatter,
  cmd = 'Format',
  ft = fts,
})

package({
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  config = conf.nvim_cmp,
  dependencies = {
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-buffer' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'rafamadriz/friendly-snippets' },
  },
})

package({ 'L3MON4D3/LuaSnip', event = 'InsertCharPre', config = conf.lua_snip })

package({ 'windwp/nvim-autopairs', event = 'InsertEnter', config = conf.auto_pairs })
