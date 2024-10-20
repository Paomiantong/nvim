local utils = require('internal.quickrun.utils')
local M = {}

M.log_level = vim.log.levels.WARN

local delete_cmd = utils.is_win() and 'del ${file_ne}.exe /f' or { 'rm', '${file_ne}', '-rf' }

M.single_file_task_template = {
  c = {
    { { 'chcp', '65001' } },
    { { 'cl', '${file}', '-o', '${file_ne}' }, exceptCode = 0 },
    { { '${file_ne}' }, { cwd = '${file_path}' } },
    { delete_cmd },
  },
  cpp = {
    { { 'g++', '${file}', '-o', '${file_ne}' }, exceptCode = 0 },
    { { '${file_ne}' }, { cwd = '${file_path}' } },
    { delete_cmd },
  },
}

return M
