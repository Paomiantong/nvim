-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT

local config = {}

function config.tokyonight()
  vim.cmd('colorscheme tokyonight-moon')
end

function config.galaxyline()
  require('modules.ui.statusline.tokyonight')
end

function config.dashboard()
  require('modules.ui.dashboard')
end

function config.nvim_bufferline()
  vim.opt.termguicolors = true
  require('modules.ui.bufferline')
end

function config.gitsigns()
  require('gitsigns').setup({
    signs = {
      add = { hl = 'GitGutterAdd', text = '▍' },
      change = { hl = 'GitGutterChange', text = '▍' },
      delete = { hl = 'GitGutterDelete', text = '▍' },
      topdelete = { hl = 'GitGutterDeleteChange', text = '▔' },
      changedelete = { hl = 'GitGutterChange', text = '▍' },
      untracked = { hl = 'GitGutterAdd', text = '▍' },
    },
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,
      ['n ]g'] = { expr = true, "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'" },
      ['n [g'] = { expr = true, "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'" },
      ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
      ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line()<CR>',
      -- Text objects
      ['o ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>',
      ['x ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>',
    },
  })
end

function config.indent_blankline()
  require('ibl').setup({
    indent = { char = '│' },
    exclude = {
      filetypes = {
        'dashboard',
        'DogicPrompt',
        'log',
        'fugitive',
        'gitcommit',
        'packer',
        'markdown',
        'txt',
        'vista',
        'help',
        'todoist',
        'NvimTree',
        'git',
        'TelescopePrompt',
        'undotree',
      },
      buftypes = { 'terminal', 'nofile', 'prompt' },
    },
  })
end

return config
