local M = {}

---@class InternalWhichPy.Config
---@field locator table<string, table> -- per-locator opts { enable=true }
---@field update_path_env boolean      -- whether to adjust PATH when selecting interpreter
---@field lsp table<string,boolean>    -- lsp client names to query workspace folders from
---@field preferred_order string[]     -- order to run locators (future use)

M.config = {
  update_path_env = true,
  cache_dir = vim.fn.stdpath('cache') .. '/whichpy',
  locator = {
    conda = { enable = true },
    pyenv = { enable = true },
    poetry = { enable = true },
    pdm = { enable = true },
    uv = { enable = true },
    workspace = { enable = true },
    global_virtual_environment = { enable = true },
    global = { enable = true },
  },
  lsp = {
    basedpyright = require('internal.whichpy.lsp.basedpyright').new(),
  },
  preferred_order = {
    'workspace',
    'conda',
    'pyenv',
    'poetry',
    'pdm',
    'uv',
    'global_virtual_environment',
    'global',
  },
}

---@param opts table|nil
function M.setup(opts)
  if not opts then
    return
  end
  M.config = vim.tbl_deep_extend('force', M.config, opts)
end

return M
