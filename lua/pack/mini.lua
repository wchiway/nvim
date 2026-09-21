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

-- 状态栏: coc 诊断计数 (b:coc_diagnostic_info 由 coc 维护)
local function coc_diagnostics()
    local info = G.b.coc_diagnostic_info
    if not info then return '' end
    local parts = {}
    for _, item in ipairs({
        { 'error', 'E', 'MiniStatuslineError' },
        { 'warning', 'W', 'MiniStatuslineWarn' },
        { 'information', 'I', 'MiniStatuslineInfo' },
        { 'hint', 'H', 'MiniStatuslineHint' },
    }) do
        local n = info[item[1]] or 0
        if n > 0 then
            table.insert(parts, string.format('%%#%s#%s%d%%#MiniStatuslineDevinfo#', item[3], item[2], n))
        end
    end
    return table.concat(parts, ' ')
end

-- 状态栏: coc-git 分支与当前 buffer 改动 (g:coc_git_status / b:coc_git_status)
local function coc_git()
    local branch = G.g.coc_git_status or ''
    local changes = G.b.coc_git_status or ''
    return G.fn.trim(branch .. ' ' .. changes)
end

local function statusline_active()
    local MS = require('mini.statusline')
    local mode, mode_hl = MS.section_mode({ trunc_width = 120 })
    local git           = coc_git()
    local diagnostics   = coc_diagnostics()
    local filename      = MS.section_filename({ trunc_width = 140 })
    local fileinfo      = MS.section_fileinfo({ trunc_width = 120 })
    local location      = MS.section_location({ trunc_width = 75 })
    local search        = MS.section_searchcount({ trunc_width = 75 })
    return MS.combine_groups({
        { hl = mode_hl,                 strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=',
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl,                 strings = { search, location } },
    })
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

    -- 状态栏: 诊断 / git 段改读 coc 的变量 (mini 默认读 vim.diagnostic / vim.lsp, coc 不往那里写)
    require('mini.statusline').setup({
        use_icons = false,
        content = { active = statusline_active },
    })
    -- coc 更新诊断 / git 状态后立即刷新状态栏
    G.cmd([[au User CocDiagnosticChange,CocStatusChange,CocGitStatusChange redrawstatus]])

    require('mini.tabline').setup({ show_icons = false })
end

return M
