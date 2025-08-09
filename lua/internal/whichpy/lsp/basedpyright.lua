---@class InternalWhichPy.PyrightHandler: InternalWhichPy.LspHandler
---@field snapshot? table
---@field server_default? table
local M = {}
M.__index = M

function M.new()
  local obj = {
    server_default = {
      python_path = nil,
    },
  }
  return setmetatable(obj, M)
end

function M:snapshot_settings(client)
  if self.snapshot ~= nil then
    return
  end
  self.snapshot = {}

  if client.settings.python then
    self.snapshot.python_path = client.settings.python.pythonPath
  else
    self.snapshot.python_path = self.server_default.python_path
  end
end

function M:restore_snapshot(client)
  self:set_python_path(client, nil)
end

function M:set_python_path(client, python_path)
  python_path = python_path or self.snapshot.python_path

  if python_path then
    if client.settings then
      client.settings.python = vim.tbl_deep_extend('force', client.settings.python or {}, { pythonPath = python_path })
    else
      client.config.settings =
        vim.tbl_deep_extend('force', client.config.settings, { python = { pythonPath = python_path } })
    end
    client.notify('workspace/didChangeConfiguration', { settings = nil })
  else
    vim.cmd(('LspRestart %s'):format(client.id))
  end
end

return M
