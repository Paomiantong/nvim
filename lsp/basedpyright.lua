return {
  settings = {
    basedpyright = {
      analysis = { typeCheckingMode = 'basic' },
    },
  },
  root_makers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
  },
  filetypes = { 'python' },
  cmd = { 'basedpyright-langserver', '--stdio' },
}
