local G = require('G')
local M = {}

-- 可视模式下把选中内容用 left/right 包裹 (替代原 vim-surround 的 SurroundVaddPairs)
function G_vaddPairs(left, right)
    local s = G.fn.getpos("'<")
    local e = G.fn.getpos("'>")
    -- 行选择模式(V)下 '> 的列号是最大整数, 需夹到行长范围内
    local scol = math.min(s[3] - 1, #G.fn.getline(s[2]))
    local ecol = math.min(e[3], #G.fn.getline(e[2]))
    local lines = G.api.nvim_buf_get_text(0, s[2] - 1, scol, e[2] - 1, ecol, {})
    lines[1] = left .. lines[1]
    lines[#lines] = lines[#lines] .. right
    G.api.nvim_buf_set_text(0, s[2] - 1, scol, e[2] - 1, ecol, lines)
end

function M.config()
    -- 可视模式下直接按括号/引号包裹选中内容
    local pairs_map = {}
    for _, p in ipairs({ { '(', ')' }, { '[', ']' }, { '{', '}' }, { '"', '"' }, { "'", "'" }, { '`', '`' } }) do
        table.insert(pairs_map, { 'v', p[1], string.format(':<c-u>call v:lua.G_vaddPairs(%q, %q)<cr>', p[1], p[2]), { noremap = true, silent = true } })
    end
    G.map(pairs_map)

    -- 注释: 使用 nvim 0.10 内置 gc  ??行注释  可视模式 / 注释
    G.map({
        { 'n', '??', 'gcc', {} },
        { 'v', '/',  'gc',  {} },
    })
    -- MiniIndentscopeSymbol / MiniHipatterns* 等高亮在 pack/token.lua 里定义
end

-- 状态栏辅助: 给一段文字套高亮并回到基础组
local function hl_wrap(group, text, base)
    return string.format('%%#%s#%s%%#%s#', group, text, base)
end

-- 状态栏: coc 诊断计数 (b:coc_diagnostic_info 由 coc 维护), Nerd Font 图标
local function coc_diagnostics()
    local info = G.b.coc_diagnostic_info
    if not info then return '' end
    local parts = {}
    for _, item in ipairs({
        { 'error',       '󰅚 ', 'MiniStatuslineError' },
        { 'warning',     '󰀪 ', 'MiniStatuslineWarn' },
        { 'information', '󰋽 ', 'MiniStatuslineInfo' },
        { 'hint',        '󰌶 ', 'MiniStatuslineHint' },
    }) do
        local n = info[item[1]] or 0
        if n > 0 then
            table.insert(parts, hl_wrap(item[3], item[2] .. n, 'MiniStatuslineDevinfo'))
        end
    end
    return table.concat(parts, ' ')
end

-- 状态栏: coc-git 分支 (g:coc_git_status, 自带  前缀) 与当前 buffer 的 +N ~N -N 三色改动
local function coc_git()
    local branch = (G.g.coc_git_status or ''):gsub('%%', '%%%%')
    local out = {}
    if branch ~= '' then table.insert(out, hl_wrap('MiniStatuslineBranch', branch, 'MiniStatuslineDevinfo')) end
    local changes = G.b.coc_git_status or ''
    for sym, group in pairs({ ['+'] = 'MiniStatuslineAdded', ['~'] = 'MiniStatuslineChanged', ['-'] = 'MiniStatuslineRemoved' }) do
        local n = changes:match('%' .. sym .. '(%d+)')
        if n then table.insert(out, hl_wrap(group, sym .. n, 'MiniStatuslineDevinfo')) end
    end
    return table.concat(out, ' ')
end

-- 状态栏: 文件图标 + 相对路径 + 修改/只读标记
local function file_section()
    if G.o.buftype == 'terminal' then return '%t' end
    local icon = ''
    if _G.MiniIcons then
        local glyph, group = _G.MiniIcons.get('file', G.api.nvim_buf_get_name(0))
        icon = hl_wrap(group, glyph, 'MiniStatuslineFilename') .. ' '
    end
    local flags = ''
    if G.o.modified then flags = flags .. hl_wrap('MiniStatuslineModified', ' ●', 'MiniStatuslineFilename') end
    if G.o.readonly then flags = flags .. ' ' end
    return icon .. '%f' .. flags
end

-- 状态栏: coc 服务状态 (语言服务名 / 进度), % 需转义
local function coc_status()
    local s = G.g.coc_status or ''
    if s == '' then return '' end
    return hl_wrap('MiniStatuslineLsp', (s:gsub('%%', '%%%%')), 'MiniStatuslineDevinfo')
end

-- 状态栏: 文件类型图标 + 名称
local function filetype_section()
    local ft = G.o.filetype
    if ft == '' then return '' end
    if _G.MiniIcons then
        local glyph, group = _G.MiniIcons.get('filetype', ft)
        return hl_wrap(group, glyph, 'MiniStatuslineFileinfo') .. ' ' .. ft
    end
    return ft
end

local function statusline_active()
    local MS = require('mini.statusline')
    local mode, mode_hl = MS.section_mode({ trunc_width = 120 })
    local search        = MS.section_searchcount({ trunc_width = 75 })
    return MS.combine_groups({
        { hl = mode_hl,                  strings = { mode } },
        { hl = 'MiniStatuslineDevinfo',  strings = { coc_git(), coc_diagnostics() } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { file_section() } },
        '%=',
        { hl = 'MiniStatuslineDevinfo',  strings = { coc_status() } },
        { hl = 'MiniStatuslineFileinfo', strings = { filetype_section() } },
        { hl = mode_hl,                  strings = { search, '%l:%-2v', '%P' } },
    })
end

local function statusline_inactive()
    return '%#MiniStatuslineInactive# %f%m%r %='
end

function M.setup()
    -- ys 添加  ds 删除  cs 替换  (s 前缀已用于窗口操作)
    require('mini.surround').setup({
        mappings = {
            add = 'ys', delete = 'ds', replace = 'cs',
            find = '', find_left = '', highlight = '', update_n_lines = '',
            suffix_last = '', suffix_next = '',
        },
        search_method = 'cover_or_next',
    })

    require('mini.pairs').setup({
        modes = { insert = true, command = false, terminal = false },
    })

    require('mini.indentscope').setup({
        symbol = '│',
        draw = { animation = require('mini.indentscope').gen_animation.none() },
        options = { try_as_border = true },
    })
    G.cmd([[au FileType help,terminal,lazy let b:miniindentscope_disable = v:true]])

    local hipatterns = require('mini.hipatterns')
    hipatterns.setup({
        highlighters = {
            fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
            hack      = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack' },
            todo      = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo' },
            note      = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote' },
            hex_color = hipatterns.gen_highlighter.hex_color(),
        },
    })

    -- 图标提供者 (Nerd Font, 终端已用 Hack Nerd Font); statusline / tabline 自动取用
    require('mini.icons').setup()

    -- 光标下的词在别处淡色标出
    require('mini.cursorword').setup({ delay = 150 })
    G.cmd([[au FileType help,terminal,lazy let b:minicursorword_disable = v:true]])

    -- 状态栏: 诊断 / git 段改读 coc 的变量 (mini 默认读 vim.diagnostic / vim.lsp, coc 不往那里写)
    require('mini.statusline').setup({
        use_icons = true,
        content = { active = statusline_active, inactive = statusline_inactive },
    })
    -- coc 更新诊断 / git / 服务状态后立即刷新状态栏
    G.cmd([[au User CocDiagnosticChange,CocStatusChange,CocGitStatusChange redrawstatus]])

    -- 标签栏: 文件图标 + 名称, 修改过的加 ●
    require('mini.tabline').setup({
        show_icons = true,
        format = function(buf_id, label)
            local icon = _G.MiniIcons and (_G.MiniIcons.get('file', G.api.nvim_buf_get_name(buf_id))) or ''
            local mark = G.api.nvim_get_option_value('modified', { buf = buf_id }) and ' ●' or ''
            return string.format(' %s %s%s ', icon, label, mark)
        end,
    })
end

return M
