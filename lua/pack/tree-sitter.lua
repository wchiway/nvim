local G = require('G')
local M = {}

function M.config()
    G.hi({
        ["@identifier"] = { fg = "NONE" }, -- 32
        ["@variable"] = { fg = "NONE" }, -- 32
        ["@function"] = { fg = "#0087ff" }, -- 32
        ["@function.call"] = { fg = "#0087ff" }, -- 32
        ["@operator"] = { fg = "#d75f00" }, -- 32
        ["@keyword.operator"] = { fg = "#d75f00" }, -- 32

        ["@property"] = { fg = "#d78700" }, -- 32
        ["@field"] = { fg = "#afd7af" }, -- 32
        ["@method"] = { fg = "#d75f00" }, -- 32
        ["@method.call"] = { fg = "#ff0000" }, -- 32
        ["@parameter"] = { fg = "#ff0000" }, -- 32

        ["@keyword"] = { fg = "#ff6666" }, -- 32
        ["@keyword.function"] = { fg = "#0087ff" }, -- 32
        ["@exception"] = { fg = "#0087ff" }, -- 32

        ["@statement"] = { fg = "#d75f00" }, -- 32
        ["@special"] = { fg = "#d78700" }, -- 32
        ["@comment"] = { fg = "#5faf5f", italic = true }, -- 32
        ["@include"] = { fg = "#800000" }, -- 32
        ["@type"] = { fg = "#d7af5f" }, -- 32
        ["@type.builtin"] = { fg = "#afd7af" }, -- 32
        ["@punctuation.bracket"] = { fg = "#afd7d7" }, -- 32

        ["@constructor"] = { fg = "#d78700" }, -- 32
        ["@namespace"] = { fg = "#d78700" }, -- 32

        ["@string"] = { fg = "#00afaf" }, -- 32
        ["@number"] = { fg = "#00afaf" }, -- 32
        ["@boolean"] = { fg = "#00afaf" }, -- 32

        ["@tag"] = { fg = "#d78700" }, -- 32
        ["@tag.attribute"] = { fg = "#d75f00" }, -- 32
        ["@tag.delimiter"] = { fg = "#afd7af" }, -- 32
        ["@conditional.ternary"] = { fg = "#800000" }, -- 32
        ["@punctuation.special"] = { fg = "#d78700" }, -- 32

        ["@text.literal"] = { fg = "#c0c0c0" }, -- 32

        ["@text.todo.unchecked"] = { fg = "#d78700" }, -- 32
        ["@text.todo.checked"] = { fg = "#00afaf" }, -- 32

        ["@markup.heading.1"] = { fg = "#87d7ff", bold = true }, -- 32
        ["@markup.heading.2"] = { fg = "#00afff", bold = true }, -- 32
        ["@markup.heading.3"] = { fg = "#afafff", bold = true }, -- 32
        ["@markup.heading.4"] = { fg = "#d78700", bold = true }, -- 32
        ["@markup.heading.5"] = { fg = "#d7af5f", bold = true }, -- 32
        ["@markup.heading.6"] = { fg = "#ff0000", bold = true }, -- 32

        ["@markup.raw.block@label"] = { fg = "#008000" }, -- 32

        ["@markup.raw.block"] = { fg = "#c0c0c0" }, -- 32
        ["@markup.quote"] = { fg = "#5faf5f", italic = true }, -- 32
        ["@markup.italic"] = { italic = true }, -- 32
        ["@markup.bold"] = { bold = true }, -- 32
        ["@markup.strikethrough"] = { strikethrough = true }, -- 32
        ["@markup.link"] = { fg = "#afafff", underline = true }, -- 32
        ["@markup.list"] = { fg = "#5fafd7" }, -- 32
    })
    G.map({
        { 'n', 'R', ':write | edit | TSBufEnable highlight<CR>', { silent = true, noremap = true } },
    })
    -- TODO/NOTE 高亮已交给 mini.hipatterns (见 pack/mini.lua)
end

function M.setup()
    require('nvim-treesitter.configs').setup({
        -- 固定 parser 列表; 仓库已归档, 不再对陌生文件类型自动 TSInstall
        ensure_installed = { 'typescript', 'javascript', 'vue', 'go', 'python', 'lua', 'vim', 'vimdoc',
            'bash', 'json', 'html', 'css', 'markdown', 'markdown_inline' },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "markdown" },
        },
    })
end

return M
