local config = {}

function config.telescope()
  local fb_actions = require('telescope').extensions.file_browser.actions
  require('telescope').setup({
    defaults = {
      prompt_prefix = '🔭 ',
      selection_caret = ' ',
      layout_config = {
        horizontal = { prompt_position = 'top', results_width = 0.6 },
        vertical = { mirror = false },
      },
      sorting_strategy = 'ascending',
      file_previewer = require('telescope.previewers').vim_buffer_cat.new,
      grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
      qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    },
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true,
      },
      file_browser = {
        mappings = {
          ['n'] = {
            ['c'] = fb_actions.create,
            ['r'] = fb_actions.rename,
            ['d'] = fb_actions.remove,
            ['o'] = fb_actions.open,
            ['u'] = fb_actions.goto_parent_dir,
          },
        },
      },
    },
  })
  require('telescope').load_extension('fzy_native')
  require('telescope').load_extension('dotfiles')
  require('telescope').load_extension('gosource')
  require('telescope').load_extension('file_browser')
  require('telescope').load_extension('app')
end

function config.nvim_treesitter()
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  require('nvim-treesitter.configs').setup({
    ensure_installed = 'all',
    ignore_install = { 'phpdoc' },
    highlight = {
      enable = true,
    },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
    },
  })
end

return config
