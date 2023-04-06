-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT

local package = require('core.pack').package
local conf = require('modules.completion.config')

package()

package({
    'neovim/nvim-lspconfig',
    -- used filetype to lazyload lsp
    -- config your language filetype in here
    ft = { 'lua', 'rust', 'c', 'cpp' },
    config = conf.nvim_lsp,
    dependencies = {
        { 'williamboman/mason.nvim', config = conf.mason },
        {
            'glepnir/lspsaga.nvim',
            event = 'LspAttach',
            cmd = 'Lspsaga term_toggle',
            config = conf.lspsaga,
            dependencies = {
                { "nvim-tree/nvim-web-devicons" },
                --Please make sure you install markdown and markdown_inline parser
                { "nvim-treesitter/nvim-treesitter" }
            }
        },
    }
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
    },
})

package({ 'L3MON4D3/LuaSnip', event = 'InsertCharPre', config = conf.lua_snip })

package({ 'windwp/nvim-autopairs', event = 'InsertEnter', config = conf.auto_pairs })
