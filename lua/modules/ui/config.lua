-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT
-- local map = require('core.keymap')

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

-- function config.indent_blankline()
--   require('ibl').setup({
--     indent = { char = '│' },
--     exclude = {
--       filetypes = {
--         'dashboard',
--         'DogicPrompt',
--         'log',
--         'fugitive',
--         'gitcommit',
--         'packer',
--         'markdown',
--         'txt',
--         'vista',
--         'help',
--         'todoist',
--         'NvimTree',
--         'git',
--         'TelescopePrompt',
--         'undotree',
--       },
--       buftypes = { 'terminal', 'nofile', 'prompt' },
--     },
--   })
-- end

return config
