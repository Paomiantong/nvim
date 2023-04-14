local config = require('internal.quickrun.config')
local Task = require('internal.quickrun.task')
local M = {}

local expand = vim.fn.expand ---@type function

local variables = {
  file = function()
    return expand('%:p')
  end,
  file_ne = function()
    return expand('%:p:r')
  end,
  file_path = function()
    return expand('%:p:h')
  end,
}

---example `${ file }`
local pattern = '${%s*([_%w]+)%s*}'

---@param raw_string string
---@return string
local function template(raw_string)
  local result = string.gsub(raw_string, pattern, function(x)
    local hit = variables[x]
    if hit == nil then
      return expand(x)
    end
    return hit()
  end)
  return result
end

---generate a task which run the current file
---@return quickRun.Task|nil
function M.generate_run_singlefile_task()
  local filetype = expand('%:p:e')
  local task_template = vim.deepcopy(config.single_file_task_template[filetype])

  if task_template == nil then
    return
  end

  for _, job in ipairs(task_template) do
    -- cmd
    if type(job[1]) == 'string' then
      job[1] = template(job[1])
    else
      for i, str in ipairs(job[1]) do
        job[1][i] = template(str)
      end
    end
    -- options
    for k, str in pairs(job[2] or {}) do
      job[2][k] = template(str)
    end
  end

  return Task.new(task_template)
end

return M
