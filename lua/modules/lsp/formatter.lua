require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    go = { 'goimports', 'gofmt' },
    -- Conform will run multiple formatters sequentially
    python = { 'ruff_format' },
    -- Use the "*" filetype to run formatters on all filetypes.
    ['*'] = { 'codespell' },
    -- Use the "_" filetype to run formatters on filetypes that don't
    -- have other formatters configured.
    ['_'] = { 'trim_whitespace' },
  },
  default_format_opts = {
    lsp_format = 'fallback',
  },
})

-- -- Utilities for creating configurations
-- local util = require('formatter.util')
--
-- require('formatter').setup({
--   -- Enable or disable logging
--   logging = true,
--   -- Set the log level
--   log_level = vim.log.levels.WARN,
--   -- All formatter configurations are opt-in
--   filetype = {
--     c = {
--       function()
--         return {
--           exe = 'clang-format',
--           args = {
--             '-style',
--             'file',
--             '-fallback-style',
--             'llvm',
--             '--Wno-error',
--             'unknown',
--             '-assume-filename',
--             util.escape_path(util.get_current_buffer_file_name()),
--           },
--           stdin = true,
--           try_node_modules = true,
--           cwd = util.get_cwd(),
--         }
--       end,
--       --   require('formatter.filetypes.c').clangformat,
--     },
--     cpp = {
--       require('formatter.filetypes.cpp').clangformat,
--     },
--     lua = {
--       require('formatter.filetypes.lua').stylua,
--     },
--     python = {
--       require('formatter.filetypes.python').ruff,
--     },
--     javascript = {
--       require('formatter.filetypes.javascript').prettier,
--     },
--     css = {
--       require('formatter.filetypes.css').prettier,
--     },
--     html = {
--       require('formatter.filetypes.html').prettier,
--     },
--     yaml = {
--       require('formatter.filetypes.yaml').prettier,
--     },
--     json = {
--       require('formatter.filetypes.json').prettier,
--     },
--     toml = {
--       require('formatter.filetypes.toml').tombi,
--     },
--     go = {
--       require('formatter.filetypes.go').gofmt,
--     },
--     -- Use the special "*" filetype for defining formatter configurations on
--     -- any filetype
--     ['*'] = {
--       -- "formatter.filetypes.any" defines default configurations for any
--       -- filetype
--       -- require("formatter.filetypes.any").remove_trailing_whitespace
--     },
--   },
-- })
--
-- -- Format after save
-- -- vim.cmd([[
-- -- augroup FormatAutogroup
-- -- autocmd!
-- -- autocmd BufWritePost * FormatWrite
-- -- augroup END
-- -- ]])
