local api = vim.api

local log = require('internal.quickrun.log')

---@class quickRun.Buffer
---@field bufnr number
---@field amountLines number
---@field attached boolean
---@field attach_window number
local Buffer = {}

local bufOptions = {
  buftype = 'nofile',
  swapfile = false,
  filetype = 'runner',
  bufhidden = 'hide',
  buflisted = false,
  modifiable = false,
}

---@return quickRun.Buffer buffer a new `buffer`
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
    attached = false,
  }, { __index = Buffer })
end

---render lines
---@param lines table the lines need to be rendered to the `buffer`
---@param highlight? string highlight group
function Buffer:render(lines, highlight)
  -- set lines
  api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
  api.nvim_buf_set_lines(self.bufnr, self.amountLines, -1, false, lines)
  api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
  -- highlight
  if highlight then
    for index, _ in ipairs(lines) do
      api.nvim_buf_add_highlight(self.bufnr, 0, highlight, self.amountLines + index - 1, 0, -1)
    end
  end
  -- save state
  self.amountLines = self.amountLines + #lines
  -- move cursor
  if self.attached then
    api.nvim_win_set_cursor(self.attach_window, { self.amountLines, 1 })
  end
end

---whether the `buffer` is valid
function Buffer:is_valid()
  return api.nvim_buf_is_valid(self.bufnr)
end

---delete the `buffer`
function Buffer:delete()
  api.nvim_buf_delete(self.bufnr, { force = true })
end

---@param attach_window number
function Buffer:on_attach(attach_window)
  log.info(self.bufnr .. ' attach to ' .. attach_window)
  self.attached = true
  self.attach_window = attach_window
end

function Buffer:on_detach()
  self.attached = false
  self.attach_window = -1
end

local NullBuferr = {}

NullBuferr = setmetatable(NullBuferr, { __index = Buffer })

return Buffer
