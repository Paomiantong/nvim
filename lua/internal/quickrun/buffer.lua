local api = vim.api

---@class quickRun.Buffer
---@field bufnr number
---@field amountLines number
local Buffer = {}

local bufOptions = {
  buftype = 'nofile',
  swapfile = false,
  filetype = 'runner',
  bufhidden = 'hide',
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

  return setmetatable({
    bufnr = bufnr,
    amountLines = 0,
  }, { __index = Buffer })
end

---render output
---@param data table
---@param highlight? string
function Buffer:render(data, highlight)
  api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
  api.nvim_buf_set_lines(self.bufnr, self.amountLines, -1, false, data)
  if highlight then
    for index, _ in ipairs(data) do
      api.nvim_buf_add_highlight(self.bufnr, 0, highlight, self.amountLines + index - 1, 0, -1)
    end
  end

  self.amountLines = self.amountLines + #data
  api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
end

return Buffer
