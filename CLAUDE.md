# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- Format Lua files: `stylua .`
- Check Lua formatting exactly as CI does: `stylua --check .`
- Load the config headlessly for smoke testing: `nvim --headless +qa`
- Load a specific Lua module headlessly: `nvim --headless -u NONE --cmd 'set rtp+=/data/khyou/.config/nvim' +'lua package.path = vim.fn.stdpath("config") .. "/lua/?.lua;" .. vim.fn.stdpath("config") .. "/lua/?/init.lua;" .. package.path; require("module.name")' +qa`
- Plugin operations inside Neovim: `:Lazy install`, `:Lazy update`
- Tree-sitter updates inside Neovim: `:TSUpdate`
- LSP health/log commands inside Neovim: `:checkhealth vim.lsp`, `:LspInfo`, `:LspLog`, `:LspRestart <server>`
- Task runner UI inside Neovim: `:OverseerRun`

CI only runs Stylua (`stylua --check .`). There is no Makefile, npm script, or dedicated test suite in this repository; validate behavior with formatting plus Neovim headless/runtime checks.

## Architecture

This is a Lua-first Neovim configuration derived from Cosynvim. `init.lua` is intentionally thin and delegates startup to `lua/core/init.lua`, which prepares cache/local config directories, disables selected built-in plugins, bootstraps lazy.nvim, loads options/LSP/autocmds, then loads keymaps and internal modules.

Plugin registration is centralized through `require('core.pack').package(...)`. `lua/core/pack.lua` discovers `lua/modules/**/plugins.lua`, lets those files append specs into `pack.repos`, then passes the collected specs to lazy.nvim. The README still describes older Packer APIs; follow the live lazy.nvim code instead.

Feature code is grouped by domain under `lua/modules/`:

- `lua/modules/editor/` owns editor tooling such as treesitter, snacks, noice/notify, which-key, mini.files, overseer, flash, and tmux navigation.
- `lua/modules/lsp/` owns Mason setup, completion/snippet/autopair plugins, Conform formatter setup, and the local whichpy plugin registration.
- `lua/modules/ui/` owns colorscheme, bufferline, git signs, and active Heirline statusline wiring.
- `lua/modules/tools/` contains additional tool plugins/config.

LSP behavior is split across three layers and changes often need to touch more than one layer:

1. Shared LSP UX, keymaps, diagnostics, and helper commands live in `lua/core/lsp.lua`.
2. Per-server config tables live in `lsp/*.lua`.
3. Filetype activation lives in `after/ftplugin/*.lua` via `vim.lsp.enable(...)`, except C/C++ starts clangd directly in `after/ftplugin/cpp.lua`.

Python currently enables `ty` and `ruff` from `after/ftplugin/python.lua`. `basedpyright` exists but is disabled there. Formatting is driven by Conform in `lua/modules/lsp/formatter.lua` (`stylua`, `goimports`/`gofmt`, `ruff_format`, `shfmt`, plus `codespell`/trim whitespace fallbacks).

`lua/internal/whichpy/` is a self-contained local plugin for Python interpreter discovery, cache persistence, UI selection, and LSP/DAP/env updates. It is loaded as a local lazy.nvim plugin from `lua/modules/lsp/plugins.lua`. Keep interpreter side effects centralized in `envs.lua` and adapter-specific server behavior in `lua/internal/whichpy/lsp/*.lua`.

`lua/modules/ui/heirline/statusline.lua` is the active statusline composition root and `lua/modules/ui/heirline/components.lua` is the shared component catalog. `default.lua` and `tokyonight.lua` in that subtree are legacy/alternate implementations, not the active path.

`lua/local/` is for optional local/private overrides and is loaded with `pcall`; do not assume it exists or that behavior there is shared across environments.

## Repository conventions

- Lua formatting follows `.stylua.toml`: 2 spaces, 120 columns, Unix line endings, AutoPreferSingle quotes, always keep call parentheses.
- Plugin and Mason downloads use the `gh-proxy.com` URL wrapper configured in `lua/core/pack.lua` and `lua/modules/lsp/config.lua`.
- If adding a new plugin domain under `lua/modules/`, include a `plugins.lua`; otherwise `core.pack` will not discover it.
- Existing nested guidance files may have more specific context for their subtree, especially `AGENTS.md` and `lua/modules/ui/heirline/AGENTS.md`.
