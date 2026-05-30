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
  if type(level) == 'table' then
    level = level.level
  end
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

---@return string
function M.cache_filename()
  return (vim.fn.getcwd():gsub('[\\/:]+', '%%'))
end

---@param python_path string
---@return string|nil
function M.read_pyvenv_version(python_path)
  local cfg = vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(python_path)), 'pyvenv.cfg')
  local f = io.open(cfg, 'r')
  if not f then
    return nil
  end
  local version
  for line in f:lines() do
    local v = line:match('^%s*version_info%s*=%s*([%d%.]+)') or line:match('^%s*version%s*=%s*([%d%.]+)')
    if v then
      version = v
      break
    end
  end
  f:close()
  return version
end

---@param dir_name string
---@return string|nil
function M.parse_uv_dir_version(dir_name)
  return dir_name:match('^[%w]+%-(%d[%d%.]*)')
end

return M
