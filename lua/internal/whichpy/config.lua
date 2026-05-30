local M = {}

---@class InternalWhichPy.Config
---@field locator table<string, table> -- per-locator opts { enable=true }
---@field update_path_env boolean      -- whether to adjust PATH when selecting interpreter
---@field lsp table<string, boolean|InternalWhichPy.LspHandler>
---@field preferred_order string[]     -- order to run locators (future use)

local function is_handler(handler)
  return type(handler) == 'table'
    and type(handler.set_python_path) == 'function'
    and type(handler.snapshot_settings) == 'function'
    and type(handler.restore_snapshot) == 'function'
end

local function resolve_lsp_handlers(handlers)
  local resolved = {}

  for client_name, handler in pairs(handlers or {}) do
    if handler == true then
      local mod = require('internal.whichpy.lsp.' .. client_name)
      resolved[client_name] = mod.new()
    elseif handler ~= false and handler ~= nil then
      assert(is_handler(handler), ('invalid whichpy lsp handler for %s'):format(client_name))
      resolved[client_name] = handler
    end
  end

  return resolved
end

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
    basedpyright = true,
    ty = true,
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
  if opts then
    local merged = vim.tbl_deep_extend('force', M.config, opts)
    for key in pairs(M.config) do
      M.config[key] = nil
    end
    for key, value in pairs(merged) do
      M.config[key] = value
    end
  end

  M.config.lsp = resolve_lsp_handlers(M.config.lsp)
end

return M
