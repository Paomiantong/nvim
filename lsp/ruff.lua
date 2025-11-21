return {
  cmd = { 'ruff', 'server' },
  init_options = {
    settings = {
      lint = { enable = false },
    },
  },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  filetypes = { 'python' },
}
