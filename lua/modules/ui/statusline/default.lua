local gl = require('galaxyline')
local gls = gl.section
local buffer = require('galaxyline.provider_buffer')

gl.short_line_list = {
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

local colors = {
  bg = '#1a1b26',
  line_bg = '#414868',
  fg = '#8FBCBB',
  fg_green = '#65a380',

  gray = '#3e4452',
  lightgray = '#282c34',
  darknavy = '#2c323d',
  darkgray = '#abb2bf',

  yellow = '#fabd2f',
  cyan = '#008080',
  darkblue = '#658edc',
  green = '#98C379',
  orange = '#FF8800',
  --purple = '#5d4d7a',
  purple = '#C678DD',
  magenta = '#c678dd',
  blue = '#51afef',
  red = '#ec5f67',
}

local function trailing_whitespace()
  local trail = vim.fn.search('\\s$', 'nw')
  if trail ~= 0 then
    return ' '
  else
    return nil
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

local mode_color = function()
  local mode_colors = {
    [110] = colors.green,
    [105] = colors.blue,
    [99] = colors.red,
    [116] = colors.blue,
    [118] = colors.purple,
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

gls.left[1] = {
  FirstElement = {
    provider = function()
      vim.api.nvim_command('hi GalaxyViModeBF guibg=' .. mode_color())
      return '▊ '
    end,
    highlight = 'GalaxyViModeBF',
  },
}
gls.left[2] = {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
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
      local vim_mode = vim.fn.mode()
      vim.api.nvim_command('hi GalaxyViMode guibg=' .. mode_color())
      vim.api.nvim_command('hi GalaxyViModeSP guifg=' .. mode_color() .. ' guibg=' .. colors.line_bg)
      return '  ' .. aliases[vim_mode:byte()] .. ' '
    end,
    separator = ' ',
    separator_highlight = 'GalaxyViModeSP',
    highlight = { colors.bg, colors.line_bg, 'bold' },
  },
}

gls.left[3] = {
  FileIcon = {
    provider = 'FileIcon',
    condition = buffer_not_empty,
    highlight = { require('galaxyline.provider_fileinfo').get_file_icon_color, colors.line_bg },
  },
}

gls.left[4] = {
  FileName = {
    provider = 'FileName',
    condition = buffer_not_empty,
    highlight = { colors.darkgray, colors.line_bg },
    separator = ' ',
    separator_highlight = { colors.darkgray, colors.line_bg },
  },
}

gls.left[5] = {
  FileSize = {
    provider = 'FileSize',
    condition = buffer_not_empty,
    icon = ' ',
    highlight = { colors.purple, colors.line_bg, 'bold' },
  },
}

gls.left[6] = {
  GitIcon = {
    provider = function()
      return '  '
    end,
    condition = require('galaxyline.condition').check_git_workspace,
    highlight = { colors.darkgray, colors.line_bg },
  },
}
gls.left[7] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = require('galaxyline.condition').check_git_workspace,
    highlight = { colors.orange, colors.line_bg, 'bold' },
  },
}

local checkwidth = function()
  local squeeze_width = vim.fn.winwidth(0) / 2
  if squeeze_width > 40 then
    return true
  end
  return false
end

gls.left[8] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    icon = '| ',
    highlight = { colors.green, colors.line_bg },
  },
}
gls.left[9] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    icon = '|柳',
    highlight = { colors.orange, colors.line_bg },
  },
}
gls.left[10] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    icon = '| ',
    highlight = { colors.red, colors.line_bg },
  },
}
gls.left[11] = {
  LeftEnd = {
    provider = function()
      return '|'
    end,
    separator = '',
    separator_highlight = { colors.line_bg, colors.bg },
    highlight = { colors.line_bg, colors.line_bg },
  },
}

gls.left[12] = {
  TrailingWhiteSpace = {
    provider = TrailingWhiteSpace,
    icon = '  ',
    highlight = { colors.yellow, colors.bg },
  },
}

gls.left[13] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = { colors.red, colors.bg },
  },
}
gls.left[14] = {
  Space = {
    provider = function()
      return ' '
    end,
    highlight = { colors.line_bg, colors.bg },
  },
}
gls.left[15] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = { colors.yellow, colors.bg },
  },
}

gls.right[1] = {
  ShowLspClient = {
    condition = function()
      local tbl = { ['dashboard'] = true, [''] = true }
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    separator = ' ',
    separator_highlight = { colors.line_bg, colors.bg },
    highlight = { colors.darkblue, colors.line_bg },
    icon = '   ',
    provider = 'GetLspClient',
  },
}

gls.right[2] = {
  WhiteSpaceEdge = {
    provider = function()
      return ' '
    end,
    highlight = { colors.darkblue, colors.line_bg },
    separator = ' ',
    separator_highlight = { colors.darkblue, colors.line_bg },
  },
}

gls.right[3] = {
  FileEncode = {
    provider = 'FileEncode',
    highlight = { colors.darkblue, colors.line_bg },
  },
}

gls.right[4] = {
  FileFormat = {
    provider = {
      'FileFormat',
      function()
        return ' '
      end,
    },
    highlight = { colors.darkblue, colors.line_bg },
    separator = ' | ',
    separator_highlight = { colors.darkblue, colors.line_bg },
  },
}

gls.right[5] = {
  LineInfo = {
    provider = 'LineColumn',
    highlight = { colors.bg, colors.darkblue },
    separator = '',
    separator_highlight = { colors.darkblue, colors.line_bg },
  },
}

gls.right[6] = {
  PerCent = {
    provider = 'LinePercent',
    highlight = { colors.bg, colors.darkblue },
  },
}

gls.short_line_left[1] = {
  WhiteSpace = {
    provider = function()
      return ' '
    end,
    highlight = { colors.line_bg, colors.green },
  },
}

gls.short_line_left[2] = {
  BufferType = {
    provider = function()
      return ' ' .. buffer.get_buffer_filetype() .. ' '
    end,
    separator = '',
    condition = has_file_type,
    highlight = { colors.line_bg, colors.green, 'bold' },
    separator_highlight = { colors.green, colors.darknavy },
  },
}

-- local quickRun = require('internal.quickrun')

gls.short_line_left[3] = {
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
    highlight = { colors.purple, colors.darknavy },
    separator_highlight = { colors.darknavy, colors.bg },
  },
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider = 'BufferIcon',
    separator = '',
    condition = function()
      return has_file_type() and vim.bo.filetype ~= 'runner'
    end,
    highlight = { colors.darkgray, colors.line_bg },
    separator_highlight = { colors.line_bg, colors.darknavy },
  },
}
