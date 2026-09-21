local G = require('G')
local M = {}

function M.config()
    -- do nothing
end

function M.setup()
    -- 所有自定义高亮都在这里通过 token 的 on_highlights 定义:
    -- token 加载时会 hi clear, 直接 G.hi 会被清掉; 走 token 生成的高亮则在配色重载时也保留
    require('token').setup({
        dim_inactive = true,  -- 非当前窗口整体变暗, 分屏时焦点一眼可见
        plugins = { mini = true, lazy = true },
        on_highlights = function(hl, p)
            -- mini.indentscope 缩进线: 取调色板最浅的背景色, 不抢眼
            hl.MiniIndentscopeSymbol = { fg = p.bg5 }

            -- mini.cursorword: 光标下的词在别处淡色标出, 光标所在处不标
            hl.MiniCursorword        = { bg = p.bg4 }
            hl.MiniCursorwordCurrent = {}

            -- mini.tabline: 当前 buffer 亮色加粗, 修改过的用黄色
            hl.MiniTablineCurrent         = { fg = p.fg0, bg = p.bg3, bold = true }
            hl.MiniTablineVisible         = { fg = p.fg1, bg = p.bg2 }
            hl.MiniTablineHidden          = { fg = p.fg3, bg = p.bg1 }
            hl.MiniTablineModifiedCurrent = { fg = p.yellow, bg = p.bg3, bold = true }
            hl.MiniTablineModifiedVisible = { fg = p.yellow, bg = p.bg2 }
            hl.MiniTablineModifiedHidden  = { fg = p.yellow, bg = p.bg1 }
            hl.MiniTablineFill            = { bg = p.bg1 }

            -- mini.hipatterns 关键字: 深色字 + 调色板色块
            hl.MiniHipatternsTodo  = { fg = p.bg3, bg = p.blue,   bold = true }
            hl.MiniHipatternsNote  = { fg = p.bg3, bg = p.green,  bold = true }
            hl.MiniHipatternsFixme = { fg = p.bg3, bg = p.red,    bold = true }
            hl.MiniHipatternsHack  = { fg = p.bg3, bg = p.yellow, bold = true }

            -- 状态栏各段 (背景与 MiniStatuslineDevinfo / Fileinfo 一致)
            hl.MiniStatuslineError = { fg = p.red,    bg = p.bg4, bold = true }
            hl.MiniStatuslineWarn  = { fg = p.yellow, bg = p.bg4, bold = true }
            hl.MiniStatuslineInfo  = { fg = p.blue,   bg = p.bg4 }
            hl.MiniStatuslineHint  = { fg = p.cyan,   bg = p.bg4 }
            hl.MiniStatuslineAdded   = { fg = p.green,  bg = p.bg4 }
            hl.MiniStatuslineChanged = { fg = p.yellow, bg = p.bg4 }
            hl.MiniStatuslineRemoved = { fg = p.red,    bg = p.bg4 }
            hl.MiniStatuslineBranch  = { fg = p.accent2, bg = p.bg4, bold = true }
            hl.MiniStatuslineModified = { fg = p.yellow, bg = p.bg2, bold = true }
            hl.MiniStatuslineLsp     = { fg = p.fg3, bg = p.bg4, italic = true }

            -- 尾随空格 / Tab 的 listchars 用暗色, 不干扰正文
            hl.Whitespace = { fg = p.bg5 }

            -- ui2 消息小窗与命令行: 与浮窗同底色, 分隔线用边框色
            hl.MsgArea      = { fg = p.fg0, bg = p.bg0 }
            hl.MsgSeparator = { fg = p.fg3, bg = p.bg0 }
        end,
    })
    G.cmd('colorscheme token')
end

return M
