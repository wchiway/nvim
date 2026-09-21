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

    G.hi({
        MiniIndentscopeSymbol = { fg = '#3a4f6a' },
        MiniHipatternsTodo    = { fg = '#1c1c1c', bg = '#00afd7', bold = true },
        MiniHipatternsNote    = { fg = '#1c1c1c', bg = '#5fd787', bold = true },
        MiniHipatternsFixme   = { fg = '#1c1c1c', bg = '#ff0000', bold = true },
        MiniHipatternsHack    = { fg = '#1c1c1c', bg = '#d78700', bold = true },
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

    require('mini.statusline').setup({ use_icons = false })
    require('mini.tabline').setup({ show_icons = false })
end

return M
