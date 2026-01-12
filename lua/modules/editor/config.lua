require('keymap.remap')
local map = require('core.keymap')
local cmd = map.cmd

local config = {}

function config.nvim_tree()
  require('nvim-tree').setup({
    disable_netrw = false,
    hijack_cursor = true,
    hijack_netrw = true,
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
    diagnostics = {
      enable = true,
      show_on_dirs = true,
    },
  })
end
map.n('<Leader>eo', cmd('NvimTreeToggle'), {
  desc = 'Toggle Nvim Tree',
})

function config.minifiles()
  local miniFiles = require('mini.files')
  miniFiles.setup( -- No need to copy this inside `setup()`. Will be used automatically.
    {
      -- Module mappings created only inside explorer.
      -- Use `''` (empty string) to not create one.
      mappings = {
        go_in = '<Right>',
        go_in_plus = '<S-Right>',
        go_out = '<Left>',
        go_out_plus = '<S-Left>',
      },

      -- Customization of explorer windows
      windows = {
        -- Whether to show preview of file/directory under cursor
        preview = true,
      },
    }
  )
  map.n('<Leader>ef', miniFiles.open, {
    desc = 'Open mini files',
  })
end

function config.telescope()
  local actions = require('telescope.actions')
  local fb_actions = require('telescope').extensions.file_browser.actions
  require('telescope').setup({
    defaults = {
      prompt_prefix = '🔭 ',
      selection_caret = ' ',
      layout_config = {
        horizontal = {
          prompt_position = 'top',
          results_width = 0.6,
        },
        vertical = {
          mirror = false,
        },
      },
      sorting_strategy = 'ascending',
      file_previewer = require('telescope.previewers').vim_buffer_cat.new,
      grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
      qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
      mappings = {
        i = {
          ['esc'] = actions.close,
        },
      },
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
  require('telescope').load_extension('file_browser')
end
map.n({
  ['<Leader>tf'] = {
    rhs = cmd('Telescope find_files'),
    opts = {
      desc = 'Find files',
    },
  },
  ['<Leader>tg'] = {
    rhs = cmd('Telescope live_grep'),
    opts = {
      desc = 'Live Grep',
    },
  },
})

function config.nvim_treesitter()
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  require('nvim-treesitter').setup({
    ensure_installed = { 'c', 'cpp', 'lua', 'vim', 'markdown', 'markdown_inline', 'regex', 'bash' },
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

function config.noice()
  require('noice').setup({
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
      hover = { enabled = false },
      signature = { enabled = false },
    },
    routes = {
      {
        view = 'mini',
        filter = {
          event = 'msg_showmode',
        },
      },
      {
        view = 'mini',
        filter = {
          event = 'msg_showcmd',
        },
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
  })
end

function config.snacks() end

function config.wk()
  ---@diagnostic disable-next-line: missing-fields
  require('which-key').setup({
    ---@param ctx { mode: string, operator: string }
    defer = function(ctx)
      if vim.list_contains({ 'd', 'y' }, ctx.operator) then
        return true
      end
      return vim.list_contains({ 'v', '<C-V>', 'V' }, ctx.mode)
    end,
    preset = 'modern',
    show_help = false,
    icons = {
      colors = true,
      keys = {
        Up = '􀄨',
        Down = '􀄩',
        Left = '􀄪',
        Right = '􀄫',
        C = '􀆍',
        M = '􀆕',
        S = '􀆝',
        CR = '􀅇',
        Esc = '􀆧',
        ScrollWheelDown = '󱕐',
        ScrollWheelUp = '󱕑',
        NL = '􀅇',
        BS = '􁂉',
        Space = '󱁐',
        Tab = '􀅂',
      },
    },
  })

  -- Document existing key chains
  require('which-key').add({
    {
      'g',
      group = 'Go to',
      icon = '󰿅',
    }, --   { '<leader>a', group = 'Avante', icon = '󰚩' },
    {
      '<leader>b',
      group = 'Buffer',
      icon = '',
    }, --   { '<leader>d', group = 'DAP', icon = '' },
    --   { '<leader>c', group = 'DiffView', icon = '' },
    {
      '<leader>g',
      group = 'Git',
      icon = '',
    },
    {
      '<leader>l',
      group = 'Lsp',
      mode = 'n',
      icon = '',
    }, --   { '<leader>r', group = 'Overseer tasks', mode = 'n', icon = '󰑮' },
    {
      '<leader>f',
      group = 'Find',
      mode = 'n',
    },
    {
      '<leader>t',
      group = 'Toggle',
    }, --   { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
    --   { '<leader>P', group = 'Picture', icon = '' },
    --   { '<leader>x', group = 'Execute Lua', icon = '', mode = { 'n', 'v' } },
  })
end

return config
