local G = require('G')
local M = {}

function M.config()
    -- do nothing
end

function M.setup()
    -- 所有自定义高亮都在这里通过 token 的 on_highlights 定义:
    -- token 加载时会 hi clear, 直接 G.hi 会被清掉; 走 token 生成的高亮则在配色重载时也保留
    require('token').setup({
        plugins = { mini = true, lazy = true },
        on_highlights = function(hl, p)
            -- mini.indentscope 缩进线: 取调色板最浅的背景色, 不抢眼
            hl.MiniIndentscopeSymbol = { fg = p.bg5 }

            -- mini.hipatterns 关键字: 深色字 + 调色板色块
            hl.MiniHipatternsTodo  = { fg = p.bg3, bg = p.blue,   bold = true }
            hl.MiniHipatternsNote  = { fg = p.bg3, bg = p.green,  bold = true }
            hl.MiniHipatternsFixme = { fg = p.bg3, bg = p.red,    bold = true }
            hl.MiniHipatternsHack  = { fg = p.bg3, bg = p.yellow, bold = true }

            -- 状态栏里 coc 诊断计数用的高亮, 背景与 MiniStatuslineDevinfo 一致
            hl.MiniStatuslineError = { fg = p.red,    bg = p.bg4, bold = true }
            hl.MiniStatuslineWarn  = { fg = p.yellow, bg = p.bg4, bold = true }
            hl.MiniStatuslineInfo  = { fg = p.blue,   bg = p.bg4 }
            hl.MiniStatuslineHint  = { fg = p.cyan,   bg = p.bg4 }

            -- 尾随空格 / Tab 的 listchars 用暗色, 不干扰正文
            hl.Whitespace = { fg = p.bg5 }
        end,
    })
    G.cmd('colorscheme token')
end

return M
