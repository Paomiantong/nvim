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
    ['<Leader>tf'] = cmd('Telescope find_files')
})

-- Lspsaga
-- floaterminal
map.nt('<A-d>', cmd('Lspsaga term_toggle'))
map.nx({
    -- code action
    ['<A-Enter>'] = cmd('Lspsaga code_action'),
    -- outline
    ['<Leader>o'] = cmd('Lspsaga outline')
})
-- hover_doc
map.n('<Leader>h', cmd('Lspsaga hover_doc<CR>'))
-- If you want to keep the hover window in the top right hand corner,
-- you can pass the ++keep argument
-- Note that if you use hover with ++keep, pressing this key again will
-- close the hover window. If you want to jump to the hover window
-- you should use the wincmd command "<C-w>w"
-- map.n('<A-a>', cmd('Lspsaga hover_doc ++keep<CR>'))
