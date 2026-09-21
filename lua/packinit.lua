local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local G = require('G')

require("lazy").setup({
    -- 配色方案 (自定义高亮见 pack/token.lua)
    {
        'ThorstenRhau/token',
        lazy = false,
        priority = 1000,
        init = function() require('pack/token').config() end,
        config = function() require('pack/token').setup() end
    },

    -- vv 快速选中内容插件 (延迟加载)
    {
        'terryma/vim-expand-region',
        event = 'VeryLazy',
        init = function() require('pack/vim-expand-region').config() end,
        config = function() require('pack/vim-expand-region').setup() end
    },

    -- ff 高亮光标下的word FF取消全部高亮 (延迟加载)
    {
        'Mr-LLLLL/interestingwords.nvim',
        keys = { 'ff', 'FF' },
        event = 'VeryLazy',
        config = function() require('pack/interestingwords-nvim').setup() end
    },

    -- coc-nvim (核心插件)
    {
        'neoclide/coc.nvim',
        branch = 'release',
        event = { 'BufReadPost', 'BufNewFile' }, -- BufNewFile: 新建文件也要有补全
        init = function() require('pack/coc').config() end,
        config = function() require('pack/coc').setup() end
    },

    -- 命令行边输入边提示: 使用 nvim 0.12 内置 wildtrigger() (见 profile.lua / autocmd.lua)

    -- tree-sitter (优化加载时机)
    {
        'nvim-treesitter/nvim-treesitter',
        tag = 'v0.10.0',
        build = ':TSUpdate',
        -- 必须早于 FileType：本机无内置 parser，内建 ftplugin 会调用 vim.treesitter.start()
        -- 若延迟到 VeryLazy，则 nvim <file>.lua 在启动期报 E5113（no parser for 'lua'）
        event = { 'BufReadPre', 'BufNewFile' },
        init = function()
            -- 提升解析器启动优先级但延迟执行
            require('pack/tree-sitter').config()
        end,
        config = function()
            require('pack/tree-sitter').setup()
        end
    },

    -- mini.nvim: surround / pairs / indentscope / hipatterns / statusline / tabline
    {
        'nvim-mini/mini.nvim',
        version = '*',
        lazy = false,
        init = function() require('pack/mini').config() end,
        config = function() require('pack/mini').setup() end
    },
}, {
    ui = {
        border = "rounded",
        icons = {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🗝",
            plugin = "🔌",
            runtime = "💻",
            require = "🌙",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤 ",
        },
    },
    -- 内置插件已在 init.lua 通过 vim.g.loaded_* 统一禁用, 此处不再重复
})
