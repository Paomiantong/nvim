-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT
-- recommend some vim mode key defines in this file

local keymap = require('core.keymap')
local nmap, imap, cmap, xmap = keymap.nmap, keymap.imap, keymap.cmap, keymap.xmap
local map = keymap.map
local silent, noremap = keymap.silent, keymap.noremap
local opts = keymap.new_opts
local cmd = keymap.cmd

--UP
map({ 'h', 'k', opts(noremap) })
map({ 'H', '5k', opts(noremap) })
--Down
map({ 'k', 'j', opts(noremap) })
map({ 'K', '5j', opts(noremap) })
--Left
map({ 'j', 'h', opts(noremap) })
map({ 'J', '5h', opts(noremap) })
--Right
map({ 'L', '5l', opts(noremap) })

--Search next
map({ '=', 'nzz', opts(noremap) })
--Search previous
map({ '-', 'Nzz', opts(noremap) })
--No highlight search
map({ '<Leader><CR>', ':nohlsearch<CR>', opts(noremap) })

--Search And Modify Slots
map({ '<Leader><Leader>', '<Esc>/<[]><CR>:nohlsearch<CR>c4l', opts(noremap) })

-- Use space as leader key
vim.g.mapleader = '\\'

-- leaderkey
nmap({ ' ', '', opts(noremap) })
xmap({ ' ', '', opts(noremap) })

-- usage example
nmap({
  -- noremal remap
  -- close buffer
  { '<C-x>', cmd('bdelete'), opts(noremap, silent) },
  -- save
  { '<C-s>', cmd('write'), opts(noremap) },
  -- yank
  { 'Y', 'y$', opts(noremap) },
  -- buffer jump
  { ']b', cmd('bn'), opts(noremap) },
  { '[b', cmd('bp'), opts(noremap) },
  -- remove trailing white space
  { '<Leader>t', cmd('TrimTrailingWhitespace'), opts(noremap) },
  -- window jump
  { '<C-j>', '<C-w>h', opts(noremap) },
  { '<C-l>', '<C-w>l', opts(noremap) },
  { '<C-k>', '<C-w>j', opts(noremap) },
  { '<C-h>', '<C-w>k', opts(noremap) },
})

imap({
  -- insert mode
  { '<C-h>', '<Bs>', opts(noremap) },
  { '<C-e>', '<End>', opts(noremap) },
})

-- commandline remap
cmap({ '<C-b>', '<Left>', opts(noremap) })
