local map = require('core.keymap')
local cmd = map.cmd

-- Use '\' as leader key
vim.g.mapleader = '\\'

-- move
map.a({
  --up
  ['K'] = '5k',
  --down
  ['J'] = '5j',
  --left
  ['H'] = '5h',
  --right
  ['L'] = '5l',
})

-- search
map.a({
  --Search next
  ['='] = 'nzz',
  --Search previous
  ['-'] = 'Nzz',
  --No highlight search
  ['<Leader><CR>'] = cmd('nohlsearch'),
})

-- buffer
-- close buffer
map.a('<C-x>', cmd('BufferClose'), { silent = true })
map.a({
  -- save
  ['<C-s>'] = cmd('write'),
  -- yank
  ['Y'] = 'y$',
  -- buffer jump
  [']b'] = cmd('bn'),
  ['[b'] = cmd('bp'),
})

-- window
map.a({
  -- window jump
  --up
  ['<C-k>'] = '<C-w>k',
  --down
  ['<C-j>'] = '<C-w>j',
  --left
  ['<C-h>'] = '<C-w>h',
  --right
  ['<C-l>'] = '<C-w>l',
})
