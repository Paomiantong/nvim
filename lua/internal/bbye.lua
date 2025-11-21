local api = vim.api
local M = {}

--- 通知辅助函数
local function err(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = 'Bbye' })
end

--- 创建一个新的空 buffer 并设置属性
local function new_buffer()
  vim.cmd('enew')
  vim.bo.buftype = ''
  vim.bo.swapfile = false
  vim.bo.bufhidden = 'wipe'
end

--- 核心删除逻辑
--- @param action string 'bdelete' | 'bwipeout'
--- @param force boolean 是否强制 (! bang)
--- @param buf_ref? integer|string buffer ID 或名字
function M.delete(action, force, buf_ref)
  -- 修复逻辑：优先尝试转换数字 ID，处理 bufferline 传入 "5" 这种字符串的情况
  local buf = tonumber(buf_ref)

  if not buf and buf_ref and buf_ref ~= '' then
    buf = vim.fn.bufnr(buf_ref)
  end

  if not buf then
    buf = api.nvim_get_current_buf()
  end

  -- 使用 nvim_buf_is_valid 检查更准确
  if not api.nvim_buf_is_valid(buf) then
    return err('未找到 Buffer: ' .. (buf_ref or ''))
  end

  -- 检查是否已修改且未保存
  if vim.bo[buf].modified and not force and not vim.o.confirm then
    return err('E89: Buffer ' .. buf .. ' 已修改但未保存 (请加 ! 强制执行)')
  end

  -- 如果强制删除，先隐藏，防止切换时报错
  if force then
    vim.bo[buf].bufhidden = 'hide'
  end

  local cur_win = api.nvim_get_current_win()

  -- 遍历所有窗口，如果窗口正在显示该 buffer，则切换到上一个 buffer
  for _, win in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_buf(win) == buf then
      api.nvim_set_current_win(win)

      -- 尝试切换到上一个 Buffer
      -- 优先尝试 bufferline 插件的命令，失败则使用原生 bprevious
      if not pcall(vim.cmd, 'BufferLineCyclePrev') then
        pcall(vim.cmd, 'bprevious')
      end

      -- 如果切换失败（例如只剩一个 buffer），则创建一个新的空 buffer
      if api.nvim_get_current_buf() == buf then
        new_buffer()
      end
    end
  end

  -- 恢复光标到原来的窗口（如果该窗口还存在）
  if api.nvim_win_is_valid(cur_win) then
    api.nvim_set_current_win(cur_win)
  end

  -- 如果 Buffer 还在列表中，执行删除
  if vim.fn.buflisted(buf) == 1 then
    local ok, msg = pcall(vim.cmd, string.format('%s%s %d', action, force and '!' or '', buf))
    if not ok and not msg:match('E516') then
      err(msg)
    end
  end
end

-- 导出函数别名
function M.bdelete(force, buf)
  M.delete('bdelete', force, buf)
end
function M.bwipeout(force, buf)
  M.delete('bwipeout', force, buf)
end

-- 注册命令 :BufferClose
api.nvim_create_user_command('BufferClose', function(opts)
  local buf = (opts.args and opts.args ~= '') and opts.args or nil
  M.bdelete(opts.bang, buf)
end, {
  bang = true,
  complete = 'buffer',
  desc = '安全关闭 Buffer 而不关闭窗口 (Bbye)',
  nargs = '?',
})

return M
