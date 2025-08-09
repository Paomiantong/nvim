-- Enhanced keymap library based on @ii14 version
-- Provides intuitive API for key mappings with batch mapping and advanced options
-- Import Neovim API functions
local set_keymap = vim.api.nvim_set_keymap
local buf_set_keymap = vim.api.nvim_buf_set_keymap

-----------------------------------------------------------
-- Buffer mapping management
-----------------------------------------------------------
local buf_map_cache = {}
local function get_buffer_mapper(buf)
  local fn = buf_map_cache[buf]
  if not fn then
    function fn(mode, lhs, rhs, opts)
      buf_set_keymap(buf, mode, lhs, rhs, opts)
    end
    buf_map_cache[buf] = fn
  end
  return fn
end

-----------------------------------------------------------
-- Helper functions
-----------------------------------------------------------

-- Remove multiple keys from a table
local function remove_keys(tbl, keys)
  for _, key in pairs(keys) do
    tbl[key] = nil
  end
end

-- Merge two tables
local function merge_tables(target, source)
  if not source then
    return target
  end

  for k, v in pairs(source) do
    target[k] = v
  end
  return target
end

-- Deep copy a table
local function deep_copy(obj)
  if type(obj) ~= 'table' then
    return obj
  end
  local result = {}
  for k, v in pairs(obj) do
    result[k] = type(v) == 'table' and deep_copy(v) or v
  end
  return result
end

-----------------------------------------------------------
-- Mode resolution
-----------------------------------------------------------

-- Parse mode string into a table of modes
local function resolve_mode(key)
  if #key == 0 then
    return { '' }
  end

  -- Collect mode identifiers
  local modes = {}
  for char in key:gmatch('.') do
    if not char:find('[!abcilnostvx]') then
      error(string.format('invalid mode identifier: "%s"', char))
    end
    modes[char] = true
  end

  -- Handle aliases and mode combinations
  -- a -> :map and b -> :map!
  if modes.a then
    modes.a = nil
    modes[''] = true
  end
  if modes.b then
    modes.b = nil
    modes['!'] = true
  end

  -- Combine modes: xs -> :vmap, nvo -> :map, ic -> :map!
  if modes.x and modes.s then
    modes.v = true
  end
  if modes.n and modes.v and modes.o then
    modes[''] = true
  end
  if modes.i and modes.c then
    modes['!'] = true
  end

  -- Remove redundant modes
  local redundant_keys = {}
  if modes[''] then
    vim.list_extend(redundant_keys, { 'n', 'v', 'o', 'x', 's' })
  elseif modes.v then
    vim.list_extend(redundant_keys, { 'x', 's' })
  elseif modes.l then
    vim.list_extend(redundant_keys, { '!', 'i', 'c' })
  elseif modes['!'] then
    vim.list_extend(redundant_keys, { 'i', 'c' })
  end

  remove_keys(modes, redundant_keys)
  return modes
end

-----------------------------------------------------------
-- Core mapping functions
-----------------------------------------------------------

-- Process a single mapping
local function process_single_mapping(map_func, modes, lhs, rhs, opts)
  local entry_opts = deep_copy(opts)
  local actual_rhs = rhs

  -- Check if rhs is a table with options
  if type(rhs) == 'table' and (rhs.rhs ~= nil or rhs.callback ~= nil) then
    -- Merge per-mapping options
    if rhs.opts then
      merge_tables(entry_opts, rhs.opts)
    end

    -- Set the actual mapping target
    if rhs.callback then
      entry_opts.callback = rhs.callback
      actual_rhs = ''
    else
      actual_rhs = rhs.rhs
    end
  elseif type(rhs) == 'function' then
    -- Handle function callbacks
    entry_opts.callback = rhs
    actual_rhs = ''
    if entry_opts.expr and entry_opts.replace_keycodes == nil then
      entry_opts.replace_keycodes = true
    end
  elseif type(rhs) == 'string' then
    -- Handle string commands
    entry_opts.callback = nil
    if entry_opts.expr and entry_opts.replace_keycodes == nil then
      entry_opts.replace_keycodes = false
    end
  else
    error('mapping target must be a string, function, or table with rhs/callback')
  end

  -- Create mapping for each mode
  for mode in pairs(modes) do
    map_func(mode, lhs, actual_rhs, entry_opts)
  end
end

-- Process batch mappings
local function process_batch_mappings(map_func, modes, maps, opts)
  for lhs, rhs in pairs(maps) do
    process_single_mapping(map_func, modes, lhs, rhs, opts)
  end
end

-----------------------------------------------------------
-- Metatable and indexing
-----------------------------------------------------------

local function index(self, key)
  assert(type(key) == 'string', 'invalid key: must be a string')

  -- Handle special command helper
  if key == 'cmd' then
    local cmd_fn = function(str)
      return '<cmd>' .. str .. '<CR>'
    end
    rawset(self, key, cmd_fn)
    return cmd_fn
  end

  -- Resolve modes
  local modes = resolve_mode(key)

  -- Create mapping function
  local function map_fn(arg1, arg2, arg3)
    local opts, maps

    -- Parse call pattern: (key, command, options) or (mappings_table, options)
    if type(arg1) == 'string' and (type(arg2) == 'string' or type(arg2) == 'function' or type(arg2) == 'table') then
      opts = arg3
      assert(opts == nil or type(opts) == 'table', 'options must be a table')
    elseif type(arg1) == 'table' then
      opts, maps = arg2, arg1
      assert(opts == nil or type(opts) == 'table', 'options must be a table')
    else
      error('invalid arguments: expected (string, string|function|table, table?) or (table, table?)')
    end

    -- Merge default options
    local final_opts = {}
    merge_tables(final_opts, rawget(self, 'opts'))
    merge_tables(final_opts, opts)

    -- Handle remap/noremap options
    if final_opts.remap then
      final_opts.remap = nil
      final_opts.noremap = false
    elseif final_opts.noremap == nil then
      final_opts.noremap = true
    end

    -- Select mapping function
    local map_func
    if not final_opts.buf then
      map_func = set_keymap
    else
      map_func = get_buffer_mapper(final_opts.buf)
      final_opts.buf = nil
    end

    -- Process mappings
    if not maps then
      -- Single mapping
      process_single_mapping(map_func, modes, arg1, arg2, final_opts)
    else
      -- Batch mappings
      process_batch_mappings(map_func, modes, maps, final_opts)
    end
  end

  -- Cache and return mapping function
  rawset(self, key, map_fn)
  return map_fn
end

-----------------------------------------------------------
-- Constructor and export
-----------------------------------------------------------

local mt = {
  __index = index,
}

local function new(opts)
  assert(opts == nil or type(opts) == 'table', 'options must be a table')
  return setmetatable({
    opts = opts or {},
    new = new,
  }, mt)
end

---# Enhanced Keymap Library
---
------
---*Basic Examples:*
---- Normal mode mapping
---```lua
---  map.n('a', ':a<CR>')
---```
---- Multiple modes: normal and visual mode
---```lua
---  map.nx('b', ':b<CR>')
---```
---- Aliases: `a` is `:map`, `b` is `:map!`
---```lua
---  map.a('c', ':c<CR>')
---  map.b('d', ':d<CR>')
---```
---- Mapping with options
---```lua
---  map.n('e', ':e<CR>', { buffer=0, remap=true })
---```
---- Lua function mapping
---```lua
---  map.n('f', function() print('f') end)
---```
---- Batch mapping
---```lua
---  map.n({
---    g = ':g<CR>',
---    h = ':h<CR>',
---    j = { rhs = ':j<CR>', opts = { silent = true } },
---    k = { callback = function() print('k') end, opts = { expr = true } }
---  }, { noremap = false })
---```
---
------
---*Mode Reference Table:*
--- KEY      | a n b i c v x s o t l
-------------|-----------------------
--- Normal   | ✓ ✓
--- Insert   |     ✓ ✓             ✓
--- Command  |     ✓   ✓
--- Visual   | ✓         ✓ ✓
--- Select   | ✓         ✓   ✓
--- Operator |                 ✓
--- Terminal |                   ✓
--- Lang-Arg |                     ✓
local map = new()

return map
