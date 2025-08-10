local M = {}

local uv = vim.uv or vim.loop
M.is_win = (uv.os_uname().sysname == 'Windows_NT')
M.filename = M.is_win and 'python.exe' or 'python'
M.filename_py3 = M.is_win and 'python3.exe' or 'python3'
M.bin_scripts = M.is_win and 'Scripts' or 'bin'

---@param dir string
---@param case "root" | "bin"
---@param python3 boolean|nil
---@return string
M.get_interpreter_path = function(dir, case, python3)
  python3 = python3 or false
  return vim.fs.joinpath(dir, case == 'root' and '' or M.bin_scripts, python3 and M.filename_py3 or M.filename)
end

function M.notify(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify(msg, level, { title = 'WhichPy' })
end

function M.notify_chenv(env_name, value)
  if value == nil then
    return
  end
  M.notify('$' .. env_name .. ': ' .. value)
end

function M.deduplicate(list)
  local hash, res = {}, {}
  for _, v in ipairs(list) do
    if v and v ~= '' then
      if not hash[v] then
        hash[v] = true
        res[#res + 1] = v
      end
    end
  end
  return res
end

function M.make_iter(data)
  return function()
    return coroutine.wrap(function()
      coroutine.yield(data)
    end)
  end
end

return M
