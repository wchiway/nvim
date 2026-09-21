# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal Neovim config in Lua (fork of `yaocccc/nvim`, reworked for startup speed), used directly as `~/.config/nvim`. No build, lint, CI, or test suite. Verified against Neovim 0.12.5 (installed via mise). Comments and docs are written in Chinese; match that when editing.

`AGENTS.md` in this repo is the detailed reference (conventions, per-file roles, gotchas). Read it before non-trivial changes; this file is the short version.

## Commands

```bash
# Syntax-check every Lua file without loading the config
nvim --headless -u NONE -c 'lua for _,f in ipairs(vim.fn.glob("lua/**/*.lua", false, true)) do local fn,e=loadfile(f); if not fn then print("SYNTAX "..f..": "..tostring(e)) end end' -c 'qa!'

# Runtime check: launch and watch for E5108 / lazy.nvim errors on startup
nvim

# Reinstall all plugins from scratch
rm -rf ~/.local/share/nvim/lazy
nvim --headless -c 'autocmd User LazyComplete quitall' -c 'Lazy sync'
```

In-editor: `:Lazy sync` after any change to `lua/packinit.lua`, `:StartupTime` for startup cost, `:checkhealth`.

## Architecture

Load order is fixed in `init.lua`: enable `vim.loader`, disable builtin plugins and all language providers, then `require` `profile` (options) → `packinit` (lazy.nvim spec) → `keymap` (global maps) → `autocmd` (autocmds + per-filetype setup).

- **`lua/G.lua`** is a facade over `vim.*` (`G.g/opt/fn/api/...`, plus `G.map`, `G.hi`, `G.cmd`). All config code uses `G`, not `vim.*` directly.
- **`lua/packinit.lua`** holds the entire lazy.nvim spec. Every plugin has a lazy trigger (`event`/`cmd`/`ft`/`keys`), and its body lives in `lua/pack/<name>.lua`.
- **`lua/pack/<name>.lua`** exports `M.config()` (called from lazy `init=`, runs *before* the plugin loads: globals, keymaps, vimscript) and `M.setup()` (called from `config=`, runs *after* load: `require('plugin').setup{}`). Keep both functions even if one is an explicit no-op, since `packinit.lua` calls them unconditionally.
- **Keymaps** are 4-tuples `{ mode, lhs, rhs, opts }` passed to `G.map`; the opts table is required (use `{}`), and `buffer = true` makes it buffer-local. Conditional maps are vimscript `expr` strings. No `<leader>` is defined anywhere.
- **Functions called from vimscript** (`v:lua.MagicSave()`, `v:lua.G_vaddPairs()`) are intentionally global, named `Magic*` / `G_*`. Do not make them `local`.
- **mini.nvim** (`lua/pack/mini.lua`) provides surround (`ys`/`ds`/`cs`), pairs, indentscope, hipatterns (TODO/NOTE/hex colors), statusline, and tabline. The statusline uses a custom `content.active` that reads coc's `b:coc_diagnostic_info` / `g:coc_git_status` / `b:coc_git_status` (mini's default sections read `vim.diagnostic`/`vim.lsp`, which coc never populates). Commenting uses Neovim's builtin `gc` (mapped to `??` and visual `/`). Command-line as-you-type suggestions use the builtin 0.12 `wildtrigger()` on `CmdlineChanged` (`lua/autocmd.lua`) with `wildmode=noselect:lastused,full`; no plugin.
- **Highlights**: the `token` colorscheme runs `hi clear` when it loads, so any `G.hi(...)` executed before it (i.e. from any `config()`/`init`) is wiped. All custom highlight groups live in `lua/pack/token.lua` inside `require('token').setup({ on_highlights = ... })`, keyed off the palette (`p.red`, `p.bg4`, ...). Do not add `G.hi` calls elsewhere for groups that should survive the colorscheme.
- **UI layer**: `lua/profile.lua` enables Neovim 0.12's experimental builtin `vim._core.ui2` with `cmdheight=0` (messages go to a bottom-right float, long output to the pager, `g<` recalls). `statuscolumn` is a plain `%=%l %s` (line number, then coc's git bar / diagnostic icon), `signcolumn=yes:1`. `cursorline` is always on with `cursorlineopt=number`; `lua/autocmd.lua` switches it to `line,number` in insert mode. Icons come from `mini.icons` (Nerd Font); coc's completion kind icons and diagnostic signs are set in `coc-settings.json`. Do not set `winborder` globally: coc draws its own border windows and would double up.
- **Options** live only in `lua/profile.lua`. `lua/pack/` sets no options.
- **`lua/autocmd.lua`** dispatches per-filetype setup via one `FileType` autocmd and a `map` table of `_<ft>()` functions, guarded so each runs once per buffer.
- `coc-settings.json` pairs with `lua/pack/coc.lua` (`coc_global_extensions`); edit it as strict JSON by hand.

## Adding a plugin

1. Create `lua/pack/<name>.lua` with `config()` / `setup()` returning `M`.
2. Add a spec in `lua/packinit.lua` with a lazy trigger that calls `require('pack/<name>').config()` in `init` and `.setup()` in `config`.
3. Restart and run `:Lazy sync`. Never hand-edit `lazy-lock.json`.

## Gotchas

- Neovim only loads `lua/**`. Never create root-level copies of `packinit.lua` / `profile.lua`; they are dead.
- `*:Zone.Identifier*` files are WSL alternate-data-stream stubs (now gitignored). If they reappear, delete them; never edit or cite them.
- `README.md` was rewritten on 2026-09-21 to match the current plugin set. Keep it in sync when adding or removing plugins or keymaps.
- `G.map` and `G.hi` mutate the tables passed in; don't reuse an opts/highlight table across calls.
- Per-filetype `BufWritePre` autocmds in `lua/autocmd.lua` must use `buffer = 0`, not a `pattern`, or they re-register on every buffer of that type.
- `timeoutlen` is 500. Do not set `tm` (it is an alias of `timeoutlen`, not `matchtime`).
- Undo/view state lives under `vim.fn.stdpath('state')`, not in the config dir.
- Do not add stylua/selene/luarc/editorconfig files; `editorconfig` is deliberately disabled in `profile.lua`.
