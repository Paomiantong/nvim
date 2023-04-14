local M = {}
local fn = vim.fn
local luv = vim.loop

---@return boolean
function M.is_win()
  return string.match(luv.os_uname().sysname, 'Windows') ~= nil
end

return M
