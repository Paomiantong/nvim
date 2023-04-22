local galaxyline = require('galaxyline')
local colors = require('tokyonight.colors').setup({ transform = true })
local section = galaxyline.section
local buffer = require('galaxyline.provider_buffer')

galaxyline.short_line_list = {
  'dashboard',
  'runner',
  'vista',
  'dbui',
  'term',
  'NvimTree',
  'fugitive',
  'fugitiveblame',
  'plug',
  'packer',
}

local function trailing_whitespace()
  local trail = vim.fn.search('\\s$', 'nw')
  if trail ~= 0 then
    return true
  else
    return false
  end
end

--CocStatus = get_diagnostic_info
--CocFunc = get_current_func
TrailingWhiteSpace = trailing_whitespace

local function has_file_type()
  local f_type = vim.bo.filetype
  if not f_type or f_type == '' then
    return false
  end
  return true
end

local buffer_not_empty = function()
  if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then
    return true
  end
  return false
end

local aliases = {
  [110] = 'NORMAL',
  [105] = 'INSERT',
  [99] = 'COMMAND',
  [116] = 'TERMINAL',
  [118] = 'VISUAL',
  [22] = 'V-BLOCK',
  [86] = 'V-LINE',
  [82] = 'REPLACE',
  [115] = 'SELECT',
  [83] = 'S-LINE',
}

local mode_color = function()
  local mode_colors = {
    [110] = colors.blue,
    [105] = colors.green,
    [99] = colors.yellow,
    [116] = colors.green1,
    [118] = colors.magenta,
    [22] = colors.purple,
    [86] = colors.purple,
    [82] = colors.red,
    [115] = colors.red,
    [83] = colors.red,
  }

  local color = mode_colors[vim.fn.mode():byte()]
  if color ~= nil then
    return color
  else
    return colors.purple
  end
end

local function Space()
  return ' '
end

-- -------------------------------------------------------------------------- --
--                                    left                                    --
-- -------------------------------------------------------------------------- --

section.left[1] = {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      local vim_mode = vim.fn.mode()
      vim.api.nvim_command('hi GalaxyViMode guibg=' .. mode_color())
      vim.api.nvim_command('hi GalaxyViModeSP guifg=' .. mode_color() .. ' guibg=' .. colors.fg_gutter)
      return '   ' .. aliases[vim_mode:byte()] .. ' '
    end,
    separator = ' ',
    separator_highlight = 'GalaxyViModeSP',
    highlight = { colors.black, colors.fg_gutter, 'bold' },
  },
}

section.left[2] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = require('galaxyline.condition').check_git_workspace,
    icon = ' ',
    highlight = 'GalaxyViModeSP',
    separator = ' ',
    separator_highlight = { colors.fg_gutter, colors.fg_gutter },
  },
}

section.left[3] = {
  Nosense = {
    provider = function()
      return ' '
    end,
    highlight = { colors.fg_gutter, colors.bg_statusline },
  },
}

local checkwidth = function()
  local squeeze_width = vim.fn.winwidth(0) / 2
  if squeeze_width > 40 then
    return true
  end
  return false
end

section.left[4] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = function()
      return checkwidth() and require('galaxyline.condition').check_git_workspace()
    end,
    icon = ' ',
    highlight = { colors.green, colors.bg_statusline },
  },
}

section.left[5] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = function()
      return checkwidth() and require('galaxyline.condition').check_git_workspace()
    end,
    icon = ' ',
    highlight = { colors.orange, colors.bg_statusline },
  },
}

section.left[6] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = function()
      return checkwidth() and require('galaxyline.condition').check_git_workspace()
    end,
    icon = ' ',
    highlight = { colors.red, colors.bg_statusline },
    separator = ' ',
    separator_highlight = { colors.dark5, colors.bg_statusline },
  },
}

section.left[7] = {
  TrailingWhiteSpace = {
    condition = TrailingWhiteSpace,
    provider = function()
      return ' '
    end,
    highlight = { colors.yellow, colors.bg_statusline },
  },
}

section.left[8] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = ' ',
    highlight = { colors.red, colors.bg_statusline },
  },
}
section.left[9] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = ' ',
    highlight = { colors.yellow, colors.bg_statusline },
    -- separator = ' ',
    -- separator_highlight = { colors.fg_sidebar, colors.bg_statusline },
  },
}

section.left[10] = {
  FileIcon = {
    provider = 'FileIcon',
    condition = buffer_not_empty,
    highlight = { require('galaxyline.provider_fileinfo').get_file_icon_color, colors.bg_statusline },
  },
}

section.left[11] = {
  FileName = {
    provider = 'FileName',
    condition = buffer_not_empty,
    highlight = { colors.fg_sidebar, colors.bg_statusline },
  },
}

section.left[12] = {
  FileSize = {
    provider = 'FileSize',
    condition = buffer_not_empty,
    icon = ' ',
    highlight = { colors.magenta, colors.bg_statusline },
    -- separator = ' ',
    -- separator_highlight = { colors.dark5, colors.bg_statusline },
  },
}

-- -------------------------------------------------------------------------- --
--                                    Right                                   --
-- -------------------------------------------------------------------------- --

section.right[1] = {
  Message = {
    provider = function()
      return string.sub(require('noice').api.status.message.get(), 1, 50)
    end,
    condition = require('noice').api.status.message.has,
    highlight = { colors.dark5, colors.bg_statusline },
  },
}

section.right[2] = {
  LspClient = {
    condition = function()
      local tbl = { ['dashboard'] = true, [''] = true }
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    separator = ' ',
    separator_highlight = { colors.dark5, colors.bg_statusline },
    highlight = { colors.orange, colors.bg_statusline },
    icon = '   ',
    provider = 'GetLspClient',
  },
}

section.right[3] = {
  FileInfo = {
    provider = { 'FileEncode', 'FileFormat' },
    separator = ' ',
    separator_highlight = { colors.fg_gutter, colors.bg_statusline },
    highlight = 'GalaxyViModeSP',
  },
}

section.right[4] = {
  LineInfo = {
    provider = { 'LineColumn', 'LinePercent' },
    highlight = 'GalaxyViMode',
    separator = ' ',
    separator_highlight = 'GalaxyViModeSP',
  },
}

-- gls.right[6] = {
--   PerCent = {
--     provider = 'LinePercent',
--     highlight = 'GalaxyViMode',
--   },
-- }

-- -------------------------------------------------------------------------- --
--                                 Short Line                                 --
-- -------------------------------------------------------------------------- --

section.short_line_left[1] = {
  BufferType = {
    provider = function()
      return '   ' .. buffer.get_buffer_filetype() .. ' '
    end,
    separator = '',
    condition = has_file_type,
    highlight = { colors.black, colors.blue, 'bold' },
    separator_highlight = { colors.blue, colors.fg_gutter },
  },
}

-- local quickRun = require('internal.quickrun')

section.short_line_left[2] = {
  RunnerInfo = {
    provider = function()
      local bufnr = vim.api.nvim_win_get_buf(0)
      return ' ' .. vim.api.nvim_buf_get_var(bufnr, 'task_name') .. ' '
      --   return ' ' .. (status.running and 'Running' or 'Done') .. '  JobID:' .. status.jobId .. ' '
    end,
    separator = '',
    condition = function()
      return buffer.get_buffer_filetype() == 'RUNNER'
    end,
    highlight = { colors.purple, colors.fg_gutter },
    separator_highlight = { colors.fg_gutter, colors.bg_statusline },
  },
}

section.short_line_right[1] = {
  BufferIcon = {
    provider = 'BufferIcon',
    separator = '',
    condition = function()
      return has_file_type() and vim.bo.filetype ~= 'runner'
    end,
    highlight = { colors.black, colors.blue },
    separator_highlight = { colors.blue, colors.fg_gutter },
  },
}
