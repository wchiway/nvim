local G = require('G')
local M = {}

function M.config()
    -- 语法配色全部交给 token 配色方案 (含 @markup.heading.* 等 markdown 组);
    -- 原先这里的 G.hi 会在 token 加载时被 hi clear 清掉, 且多数组名是已废弃的旧名, 故移除
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
