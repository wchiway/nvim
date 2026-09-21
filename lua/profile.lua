local G = require('G')

G.g.editorconfig = false
G.opt.termguicolors = true
G.opt.showcmd = true
G.opt.encoding = 'utf-8'
G.opt.wildmenu = true
-- 命令行自动补全 (nvim 0.12): 弹出菜单, 不预选, 最近使用优先; 触发见 autocmd.lua 的 CmdlineChanged
G.opt.wildmode = 'noselect:lastused,full'
G.opt.wildoptions = 'pum,fuzzy'
G.opt.pumheight = 10
G.opt.conceallevel = 0
G.opt.clipboard = 'unnamed,unnamedplus'
G.opt.hlsearch = true
G.opt.showmatch = true
G.opt.incsearch = true
G.opt.inccommand = 'split'  -- 改为 split 以便预览效果
G.opt.ignorecase = true
G.opt.smartcase = true
G.opt.timeoutlen = 500  -- 增加超时时间，减少误判
G.opt.ttimeoutlen = 10  -- 短超时，避免终端序列响应残留
G.opt.backspace = 'indent,eol,start'
G.opt.whichwrap = 'b,s,<,>,h,'
G.opt.mouse = 'a'
G.opt.vb = false  -- 关闭视觉提示音，提升响应
G.opt.hidden = true
G.opt.autoindent = true
G.opt.smartindent = true
G.opt.tabstop = 4
G.opt.softtabstop = 4
G.opt.shiftwidth = 4
G.opt.smarttab = true
G.opt.expandtab = true
G.opt.backup = false
G.opt.swapfile = false
G.opt.wrap = false
G.opt.undofile = true
G.opt.undodir = G.fn.stdpath('state') .. '/undo'
G.opt.viminfo = "!,'1000,<50,s10,h"
G.opt.foldenable = true
G.opt.foldmethod = 'manual'  -- 使用手动折叠而非语法折叠，减少CPU消耗
G.opt.viewdir = G.fn.stdpath('state') .. '/view'
G.opt.foldtext = 'v:lua.MagicFoldText()'
G.opt.cmdheight = 0       -- 平时不占命令行; 配合下方 ui2, 按 : 时才出现
G.opt.updatetime = 1000  -- 提高更新时间间隔，减少UI刷新频率，但不要太高以免影响用户体验
G.opt.shortmess = 'filnxtToOcIF'  -- 优化消息显示
G.opt.scrolloff = 5
G.opt.smoothscroll = true
G.opt.showmode = false
G.opt.number = true
G.opt.numberwidth = 2
G.opt.cursorline = true
G.opt.cursorlineopt = 'number'  -- 正常模式只高亮行号; 插入模式高亮整行 (见 autocmd.lua)
G.opt.signcolumn = 'yes:1'      -- 固定 1 格, 放 coc 的 git / 诊断标记
G.opt.statuscolumn = '%=%l %s'  -- 行号靠右, 标记条紧贴正文 (git 竖条 / 诊断图标)
G.opt.laststatus = 3      -- 全局状态栏 (mini.statusline)
G.opt.splitright = true   -- 新分屏放右 / 下, 与 sv / sp 的习惯一致
G.opt.splitbelow = true
G.opt.list = true         -- 只显示尾随空格与 Tab
G.opt.listchars = 'tab:▸ ,trail:·,nbsp:␣'
G.opt.fillchars = 'fold:-,eob: ,foldsep:=,msgsep:─'
G.opt.synmaxcol = 200     -- 限制语法高亮列数，提高大文件性能

-- nvim 0.12 内置 ui2: 命令行边输入边高亮, 长消息不再弹 Press ENTER 而是进分页器 (g< 回看).
-- 路由: 普通消息在右下角小窗浮现 3 秒; 列表类输出 (:ls :messages :set ...) 直接进分页器;
-- 错误 / 警告留在命令行区, 不被超时冲掉
require('vim._core.ui2').enable({
    msg = {
        targets = {
            list_cmd = 'pager', lua_print = 'pager', shell_out = 'pager', shell_err = 'pager', verbose = 'pager',
            emsg = 'cmd', echoerr = 'cmd', lua_error = 'cmd', rpc_error = 'cmd', wmsg = 'cmd',
            echo = 'msg', echomsg = 'msg', bufwrite = 'msg', undo = 'msg', quickfix = 'msg', progress = 'msg', completion = 'msg',
        },
        msg = { timeout = 3000 },
    },
})

G.cmd([[
    let &t_vb = ''
    let &t_ut = ''
]])

function MagicFoldText()
    local spacetext = ("        "):sub(0, G.opt.shiftwidth:get())
    local line = G.fn.getline(G.v.foldstart):gsub("\t", spacetext)
    local folded = G.v.foldend - G.v.foldstart + 1
    local findresult = line:find('%S')
    if not findresult then return '+ folded ' .. folded .. ' lines ' end
    local empty = findresult - 1
    local funcs = {
        [0] = function(_) return '' .. line end,
        [1] = function(_) return '+' .. line:sub(2) end,
        [2] = function(_) return '+ ' .. line:sub(3) end,
        [-1] = function(c)
            local result = ' ' .. line:sub(c + 1)
            local foldednumlen = #tostring(folded)
            for _ = 1, c - 2 - foldednumlen do result = '-' .. result end
            return '+' .. folded .. result
        end,
    }
    return funcs[empty <= 2 and empty or -1](empty) .. ' folded ' .. folded .. ' lines '
end