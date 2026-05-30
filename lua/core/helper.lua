local helper = {}
local home = vim.env.HOME

function helper.get_config_path()
  local config = os.getenv('XDG_CONFIG_HOME')
  if not config then
    return home .. '/.config/nvim'
  end
  config = vim.fs.normalize(config)
  return config .. '/nvim'
end

function helper.get_data_path()
  local data = os.getenv('XDG_DATA_HOME')
  if not data then
    return home .. '/.local/share/nvim'
  end
  data = vim.fs.normalize(data)
  return data .. '/nvim-data'
end

function helper.get_cache_path()
  local cache = os.getenv('XDG_CACHE_HOME')
  if not cache then
    return home .. '/.cache/nvim/'
  end
  cache = vim.fs.normalize(cache)
  return cache .. '/nvim-cache/'
end

-- Enable LSP servers for the current ftplugin buffer, allowing per-machine
-- overrides via `LOCALCONF.lsp[<filetype>]` set in `lua/local/init.lua`.
-- Pass `defaults` as the fallback list when no local override exists.
function helper.enable_lsp(defaults)
  local ft = vim.bo.filetype
  local servers = (LOCALCONF and LOCALCONF.lsp and LOCALCONF.lsp[ft]) or defaults
  for _, name in ipairs(servers) do
    vim.lsp.enable(name)
  end
end

return helper
