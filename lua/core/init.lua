-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT

local vim = vim
local helper = require('core.helper')
-- local home = os.getenv('HOME')
-- home = home == nil and os.getenv('XDG_CONFIG_HOME') or home
-- remove check is windows because I only use mac or linux
local cache_dir = helper.get_cache_path()

-- Create cache dir and subs dir
local createdir = function()
  local data_dir = {
    cache_dir .. 'backup',
    cache_dir .. 'session',
    cache_dir .. 'swap',
    cache_dir .. 'tags',
    cache_dir .. 'undo',
  }
  -- There only check once that If cache_dir exists
  -- Then I don't want to check subs dir exists
  if vim.fn.isdirectory(cache_dir) == 0 then
    os.execute('mkdir -p ' .. cache_dir)
    for _, v in pairs(data_dir) do
      if vim.fn.isdirectory(v) == 0 then
        os.execute('mkdir -p ' .. v)
      end
    end
  end
end

createdir()

--disable_distribution_plugins
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

-- neovide compitable
if vim.fn.exists('g:neovide') then
  vim.o.guifont = 'JetBrains Mono,CaskaydiaCove NF:h11'
  vim.opt.linespace = 0
  vim.g.neovide_scroll_animation_length = 0.3
end

require('core.pack'):boot_strap()
require('core.options')
require('keymap')
require('internal.bbye')
require('internal.quickrun')
