-- Utilities for creating configurations
local util = require('formatter.util')

require('formatter').setup({
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    c = {
      function()
        return {
          exe = 'clang-format',
          args = {
            '-style',
            'file',
            '-fallback-style',
            'llvm',
            '--Wno-error',
            'unknown',
            '-assume-filename',
            util.escape_path(util.get_current_buffer_file_name()),
          },
          stdin = true,
          try_node_modules = true,
          cwd = util.get_cwd(),
        }
      end,
      --   require('formatter.filetypes.c').clangformat,
    },
    cpp = {
      require('formatter.filetypes.cpp').clangformat,
    },
    lua = {
      require('formatter.filetypes.lua').stylua,
    },
    python = {
      require('formatter.filetypes.python').autopep8,
    },
    javascript = {
      require('formatter.filetypes.javascript').prettier,
    },
    css = {
      require('formatter.filetypes.css').prettier,
    },
    html = {
      require('formatter.filetypes.html').prettier,
    },
    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ['*'] = {
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      -- require("formatter.filetypes.any").remove_trailing_whitespace
    },
  },
})

-- Format after save
vim.cmd([[
augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost * FormatWrite
augroup END
]])
