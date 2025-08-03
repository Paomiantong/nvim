local config = {}

function config.mason()
    require('mason').setup({
        github = {
            download_url_template = "https://gh-proxy.com/https://github.com/%s/releases/download/%s/%s"
        }
    })
end

function config.lspsaga()
    require('lspsaga').setup({
        lightbulb = {
            enable = true,
            enable_in_insert = true,
            sign = true,
            sign_priority = 40,
            virtual_text = true
        },
        symbol_in_winbar = {
            enable = true,
            separator = '  '
        }
    })
end

config.auto_pairs = {
    pair_cmap = false,
    tabout = {
        enable = true,
        map = '<C-q>',
        cmap = '<C-q>',
        hopout = true
    },
    internal_pairs = {{
        '$',
        '$',
        suround = true,
        fly = true,
        dosuround = true,
        newline = true,
        space = true,
        ft = {'markdown', 'latex', 'tex'}
    }, {
        '\\[',
        '\\]',
        suround = true,
        fly = true,
        dosuround = true,
        newline = true,
        space = true,
        ft = {'markdown', 'latex', 'tex'}
    }, {
        '[',
        ']',
        fly = true,
        dosuround = true,
        newline = true,
        space = true
    }, {
        '(',
        ')',
        fly = true,
        dosuround = true,
        newline = true,
        space = true
    }, {
        '{',
        '}',
        fly = true,
        dosuround = true,
        newline = true,
        space = true
    }, {
        '"',
        '"',
        suround = true,
        multiline = false
    }, {
        "'",
        "'",
        suround = true,
        cond = function(fn)
            return not fn.in_lisp() or fn.in_string()
        end,
        alpha = true,
        nft = {'tex'},
        multiline = false
    }, {
        '`',
        '`',
        cond = function(fn)
            return not fn.in_lisp() or fn.in_string()
        end,
        nft = {'tex'},
        multiline = false
    }, {
        '``',
        "''",
        ft = {'tex'}
    }, {
        '```',
        '```',
        newline = true,
        ft = {'markdown'}
    }, {
        '<!--',
        '-->',
        ft = {'markdown', 'html'},
        space = true
    }, {
        '"""',
        '"""',
        newline = true,
        ft = {'python'}
    }, {
        "'''",
        "'''",
        newline = true,
        ft = {'python'}
    }}
}

function config.lua_snip()
    local ls = require('luasnip')
    ls.config.set_config({
        history = false,
        updateevents = 'TextChanged,TextChangedI'
    })
    require('luasnip.loaders.from_vscode').lazy_load()
    require('luasnip.loaders.from_vscode').lazy_load({
        paths = {'./snippets/'}
    })
end

function config.formatter()
    require('modules.lsp.formatter')
end

return config
