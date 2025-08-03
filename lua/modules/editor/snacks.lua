require('snacks').setup {
    notifier = {},
    picker = {
        matcher = {
            frecency = true,
            cwd_bonus = true,
            history_bonus = true
        },
        formatters = {
            icon_width = 3
        },
        win = {
            input = {
                keys = {
                    ['<Esc>'] = {
                        'close',
                        mode = {'n', 'i'}
                    }
                }
            }
        }
    },
    dashboard = {
        preset = {
            keys = {{
                icon = '󰈞 ',
                key = 'f',
                desc = 'Find files',
                action = ':lua Snacks.picker.smart()'
            }, {
                icon = ' ',
                key = 'o',
                desc = 'Find history',
                action = 'lua Snacks.picker.recent()'
            }, {
                icon = ' ',
                key = 'e',
                desc = 'New file',
                action = ':enew'
            }, {
                icon = ' ',
                key = 'o',
                desc = 'Recent files',
                action = ':lua Snacks.picker.recent()'
            }, {
                icon = '󰒲 ',
                key = 'L',
                desc = 'Lazy',
                action = ':Lazy',
                enabled = package.loaded.lazy ~= nil
            }, {
                icon = '󰔛 ',
                key = 'P',
                desc = 'Lazy Profile',
                action = ':Lazy profile',
                enabled = package.loaded.lazy ~= nil
            }, {
                icon = ' ',
                key = 'M',
                desc = 'Mason',
                action = ':Mason',
                enabled = package.loaded.lazy ~= nil
            }, {
                icon = ' ',
                key = 'q',
                desc = 'Quit',
                action = ':qa'
            }},
            header = [[
   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣭⣿⣶⣿⣦⣼⣆         
    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       
          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷⠄⠄⠄⠄⠻⠿⢿⣿⣧⣄     
           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    
          ⢠⣿⣿⣿⠈  ⠡⠌⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   
   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘⠄ ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  
  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   
 ⣠⣿⠿⠛⠄⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  
 ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇⠄⠛⠻⢷⣄ 
      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     
       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     
     ⢰⣶  ⣶ ⢶⣆⢀⣶⠂⣶⡶⠶⣦⡄⢰⣶⠶⢶⣦  ⣴⣶     
     ⢸⣿⠶⠶⣿ ⠈⢻⣿⠁ ⣿⡇ ⢸⣿⢸⣿⢶⣾⠏ ⣸⣟⣹⣧    
     ⠸⠿  ⠿  ⠸⠿  ⠿⠷⠶⠿⠃⠸⠿⠄⠙⠷⠤⠿⠉⠉⠿⠆   
    ]]
        },
        sections = {{
            section = 'header'
        }, {
            icon = ' ',
            title = 'Keymaps',
            section = 'keys',
            indent = 2,
            padding = 1
        }}
    },
    statuscolumn = {
        left = {'mark', 'git'},
        right = {'sign', 'fold'},
        folds = {
            open = true,
            git_hl = true
        },
        git = {
            patterns = {'GitSign', 'MiniDiffSign'}
        }
    }
}

-- ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
-- local progress = vim.defaulttable()
-- vim.api.nvim_create_autocmd('LspProgress', {
--   ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
--     if not client or type(value) ~= 'table' then
--       return
--     end
--     local p = progress[client.id]
--
--     for i = 1, #p + 1 do
--       if i == #p + 1 or p[i].token == ev.data.params.token then
--         p[i] = {
--           token = ev.data.params.token,
--           msg = ('[%3d%%] %s%s'):format(
--             value.kind == 'end' and 100 or value.percentage or 100,
--             value.title or '',
--             value.message and (' **%s**'):format(value.message) or ''
--           ),
--           done = value.kind == 'end',
--         }
--         break
--       end
--     end
--
--     local msg = {} ---@type string[]
--     progress[client.id] = vim.tbl_filter(function(v)
--       return table.insert(msg, v.msg) or not v.done
--     end, p)
--
--     local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
--     vim.notify(table.concat(msg, '\n'), 'info', {
--       id = 'lsp_progress',
--       title = client.name,
--       opts = function(notif)
--         notif.icon = #progress[client.id] == 0 and ' ' or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
--       end,
--     })
--   end,
-- })

local map = function(key, func, desc)
    vim.keymap.set('n', key, func, {
        desc = desc
    })
end
-- all keymaps for snacks.picker
map('<leader>ff', Snacks.picker.smart, 'Smart find file')
map('<leader>fo', Snacks.picker.recent, 'Find recent file')
map('<leader>fw', Snacks.picker.grep, 'Find content')
map('<leader>fh', function()
    Snacks.picker.help {
        layout = 'dropdown'
    }
end, 'Find in help')
map('<leader>fl', Snacks.picker.picker_layouts, 'Find picker layout')
map('<leader>fk', function()
    Snacks.picker.keymaps {
        layout = 'dropdown'
    }
end, 'Find keymap')
map('<leader><leader>', function()
    Snacks.picker.buffers {
        sort_lastused = true
    }
end, 'Find buffers')
map('<leader>fm', Snacks.picker.marks, 'Find mark')
map('<leader>fn', function()
    Snacks.picker.notifications {
        layout = 'dropdown'
    }
end, 'Find notification')
map('<leader>fs', Snacks.picker.lsp_workspace_symbols, 'Find workspace symbol')
map('<leader>ls', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients {
        bufnr = bufnr
    }
    local function has_lsp_symbols()
        for _, client in ipairs(clients) do
            if client.server_capabilities.documentSymbolProvider then
                return true
            end
        end
        return false
    end
    local picker_opts = {
        layout = 'left',
        tree = true,
        on_show = function()
            vim.cmd.stopinsert()
        end
    }
    if has_lsp_symbols() then
        Snacks.picker.lsp_symbols(picker_opts)
    else
        Snacks.picker.treesitter()
    end
end, 'Find symbol in current buffer')
map('<leader>fi', Snacks.picker.icons, 'Find icon')
map('<leader>fb', Snacks.picker.lines, 'Find lines in current buffer')
map('<leader>fd', Snacks.picker.diagnostics, 'Find diagnostic')
map('<leader>fH', Snacks.picker.highlights, 'Find highlight')
map('<leader>fc', function()
    Snacks.picker.files {
        cwd = vim.fn.stdpath 'config'
    }
end, 'Find nvim config file')
map('<leader>f/', Snacks.picker.search_history, 'Find search history')
map('<leader>fj', Snacks.picker.jumps, 'Find jump')
map('<leader>ft', function()
    if vim.bo.filetype == 'markdown' then
        Snacks.picker.grep_buffers {
            finder = 'grep',
            format = 'file',
            prompt = ' ',
            search = '^\\s*- \\[ \\]',
            regex = true,
            live = false,
            args = {'--no-ignore'},
            on_show = function()
                vim.cmd.stopinsert()
            end,
            buffers = false,
            supports_live = false,
            layout = 'ivy'
        }
    else
        Snacks.picker.todo_comments {
            keywords = {'TODO', 'FIX', 'FIXME', 'HACK'},
            layout = 'select'
        }
    end
end, 'Find todo')
-- other snacks features
map('<leader>bc', Snacks.bufdelete.delete, 'Delete buffers')
map('<leader>bC', Snacks.bufdelete.other, 'Delete other buffers')
map('<leader>gg', function()
    Snacks.lazygit {
        cwd = Snacks.git.get_root()
    }
end, 'Open lazygit')
map('<leader>n', Snacks.notifier.show_history, 'Notification history')
map('<leader>gb', Snacks.git.blame_line, 'Git blame line')

