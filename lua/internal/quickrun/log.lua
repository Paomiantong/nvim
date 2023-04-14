local M = {}

local config = require('internal.quickrun.config')

M.notify_opts = { title = 'QuickRun' }

function M.trace(txt)
  if config.log_level <= vim.log.levels.TRACE then
    -- NOTE: lsp thinks vim.notify takes one argument
    ---@diagnostic disable-next-line
    vim.notify(txt, vim.log.levels.TRACE, M.notify_opts)
  end
end

function M.debug(txt)
  if config.log_level <= vim.log.levels.DEBUG then
    -- NOTE: lsp thinks vim.notify takes one argument
    ---@diagnostic disable-next-line
    vim.notify(txt, vim.log.levels.DEBUG, M.notify_opts)
  end
end

function M.info(txt)
  if config.log_level <= vim.log.levels.INFO then
    -- NOTE: lsp thinks vim.notify takes one argument
    ---@diagnostic disable-next-line
    vim.notify(txt, vim.log.levels.INFO, M.notify_opts)
  end
end

function M.warn(txt)
  if config.log_level <= vim.log.levels.WARN then
    -- NOTE: lsp thinks vim.notify takes one argument
    ---@diagnostic disable-next-line
    vim.notify(txt, vim.log.levels.WARN, M.notify_opts)
  end
end

function M.error(txt)
  if config.log_level <= vim.log.levels.ERROR then
    -- NOTE: lsp thinks vim.notify takes one argument
    ---@diagnostic disable-next-line
    vim.notify(txt, vim.log.levels.ERROR, M.notify_opts)
  end
end

return M
