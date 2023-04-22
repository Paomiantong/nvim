-- recommend plugins key defines in this file

require('keymap.remap')
local map = require('core.keymap')
local cmd = map.cmd

map.n({
  -- packer
  ['<Leader>pu'] = cmd('Lazy update'),
  ['<Leader>pi'] = cmd('Lazy install'),
  -- dashboard
  ['<Leader>n'] = cmd('Dashboard'),
  -- nvimtree
  ['<Leader>e'] = cmd('NvimTreeToggle'),
  -- telescope
  ['<Leader>tf'] = cmd('Telescope find_files'),
})

map.n({
  -- formatter
  ['<space>f'] = cmd('Format'),
}, { silent = true })

-- Lspsaga
-- floaterminal
map.nt('<A-d>', cmd('Lspsaga term_toggle'))
map.nx({
  -- code action
  ['<A-Enter>'] = cmd('Lspsaga code_action'),
  -- outline
  ['<Leader>o'] = cmd('Lspsaga outline'),
})
map.n({
  -- hover_doc
  ['<space>h'] = cmd('Lspsaga hover_doc'),
  -- Rename
  ['<space>r'] = cmd('Lspsaga rename ++project'),
  -- Diagnostic show,
  ['se'] = cmd('Lspsaga show_buf_diagnostics'),
  -- Diagnostic jump
  -- You can use <C-o> to jump back to your previous location
  ['[e'] = cmd('Lspsaga diagnostic_jump_prev'),
  [']e'] = cmd('Lspsaga diagnostic_jump_next'),
  -- Diagnostic jump with filters such as only jumping to an error
  ['[E'] = function()
    require('lspsaga.diagnostic'):goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end,
  [']E'] = function()
    require('lspsaga.diagnostic'):goto_next({ severity = vim.diagnostic.severity.ERROR })
  end,
})
