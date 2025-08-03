local map = require('core.keymap')
local cmd = map.cmd

-- Use '\' as leader key
vim.g.mapleader = '\\'

-- move
map.a({
  --up
  ['h'] = 'k',
  ['H'] = '5k',
  --down
  ['k'] = 'j',
  ['K'] = '5j',
  --left
  ['j'] = 'h',
  ['J'] = '5h',
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
  ['<C-h>'] = '<C-w>k',
  --down
  ['<C-k>'] = '<C-w>j',
  --left
  ['<C-j>'] = '<C-w>h',
  --right
  ['<C-l>'] = '<C-w>l',
})
