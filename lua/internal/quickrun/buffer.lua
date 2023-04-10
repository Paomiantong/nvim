local api = vim.api

---@class quickRun.Buffer
---@field bufnr number
---@field amountLines number
local Buffer = {}

local bufOptions = {
  buftype = 'nofile',
  swapfile = false,
  filetype = 'runner',
  bufhidden = 'wipe',
  buflisted = false,
  modifiable = false,
}

---@return quickRun.Buffer
function Buffer.new()
  local bufnr = api.nvim_create_buf(false, true)

  api.nvim_buf_set_name(bufnr, 'Runner#' .. bufnr)
  -- set buffer options
  for option, value in pairs(bufOptions) do
    api.nvim_buf_set_option(bufnr, option, value)
  end

  local o = {
    bufnr = bufnr,
    amountLines = 0,
  }
  setmetatable(o, Buffer)
  return o
end

function Buffer:render(data)
  api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
  api.nvim_buf_set_lines(self.bufnr, self.amountLines, -1, false, data)
  self.amountLines = self.amountLines + #data
  api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
end

return Buffer
