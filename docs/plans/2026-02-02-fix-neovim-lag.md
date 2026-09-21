# Neovim Performance Optimization Plan

> **For Gemini:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Apply pre-configured optimizations to `profile.lua` and `packinit.lua` to resolve Neovim performance issues (lag/stuttering).

**Architecture:** Replace active configuration files in `lua/` directory with the optimized versions found in the project root.

**Tech Stack:** Neovim (Lua)

---

### Task 1: Apply Profile Optimization

**Files:**
- Source: `optimized_profile.lua` (Root)
- Target: `lua/profile.lua`

**Step 1: Verify Content**
Read `optimized_profile.lua` to ensure it contains expected optimizations (Completed in analysis phase: confirmed `updatetime=1000`, `lazyredraw=true`, etc.).

**Step 2: Apply Optimization**
Overwrite `lua/profile.lua` with the content of `optimized_profile.lua`.

```bash
cp optimized_profile.lua lua/profile.lua
```

**Step 3: Verify Change**
Read `lua/profile.lua` to confirm it now starts with `local G = require('G')` and contains `G.opt.updatetime = 1000`.

**Step 4: Commit**
```bash
git add lua/profile.lua
git commit -m "perf: apply profile optimizations (updatetime, lazyredraw)"
```

### Task 2: Apply Plugin Optimization

**Files:**
- Source: `optimized_packinit.lua` (Root)
- Target: `lua/packinit.lua`

**Step 1: Verify Content**
Read `optimized_packinit.lua` to ensure it contains lazy loading configurations (Completed in analysis phase: confirmed `event = 'VeryLazy'` for multiple plugins).

**Step 2: Apply Optimization**
Overwrite `lua/packinit.lua` with the content of `optimized_packinit.lua`.

```bash
cp optimized_packinit.lua lua/packinit.lua
```

**Step 3: Verify Change**
Read `lua/packinit.lua` to confirm it includes the `performance` block in `lazy.setup`.

**Step 4: Commit**
```bash
git add lua/packinit.lua
git commit -m "perf: apply plugin optimizations (lazy loading, disabled built-ins)"
```

### Task 3: Final Verification & Instructions

**Step 1: Check for other heavy files**
Briefly check `lua/pack/coc.lua` if it exists, to ensure it doesn't conflict. (Optional, as `packinit.lua` controls when it loads).

**Step 2: Create User Instructions**
Create a `POST_INSTALL.md` file or print instructions for the user to run `Lazy sync`.

```markdown
# Optimization Complete

To finalize the changes:
1. Restart Neovim.
2. If you see errors or if plugins are missing, run `:Lazy sync`.
3. If using CoC, ensure `coc-settings.json` is valid.
```
