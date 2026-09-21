local G = require('G')

-- 以下是全局的autocmd

G.api.nvim_create_autocmd({ "BufEnter" }, { command = [[if &buftype == '' && &readonly == 1 | set buftype=acwrite | set noreadonly | endif]] })
G.api.nvim_create_autocmd({ "BufReadPost" }, { command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]] })
G.api.nvim_create_autocmd({ "FileType" }, { command = "try | silent! loadview | catch | endtry" })
G.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, { command = "silent! mkview" })
-- 正常模式只高亮行号, 插入模式高亮整行 (cursorline 常开, 见 profile.lua)
G.api.nvim_create_autocmd({ "InsertEnter" }, { command = "set cursorlineopt=line,number" })
G.api.nvim_create_autocmd({ "InsertLeave" }, { command = "set cursorlineopt=number" })
-- 命令行 (: / ?) 边输入边弹出补全菜单 (替代 wilder.nvim)
G.api.nvim_create_autocmd({ "CmdlineChanged" }, { pattern = { ":", "/", "?" }, command = "call wildtrigger()" })

-- 以下是for不同文件类型的相关配置

local function _go()
    -- buffer = 0: 只作用于当前 buffer, 避免每打开一个 go 文件就多注册一份全局自动命令
    G.api.nvim_create_autocmd({ "BufWritePre" }, { buffer = 0, command = "silent! call CocAction('runCommand', 'editor.action.organizeImport')" })
    G.api.nvim_create_autocmd({ "BufWritePre" }, { buffer = 0, command = "call CocAction('format')" })
    G.map({ { "v", "D", ":<c-u>call v:lua.G_vaddPairs(\"/** \", \" */\")<cr>", { noremap = true, silent = true, buffer = true } }, })
end

local function _javascript()
    G.map({
        { "v", "D", ":<c-u>call v:lua.G_vaddPairs(\"/** \", \" */\")<cr>", { noremap = true, silent = true, buffer = true } },
        { "v", "T", ":<c-u>call v:lua.G_vaddPairs(\"try {\", \"} catch (e) {}\")<cr>", { noremap = true, silent = true, buffer = true } },
    })
end

local function _typescript()
    G.map({
        { "v", "D", ":<c-u>call v:lua.G_vaddPairs(\"/** \", \" */\")<cr>", { noremap = true, silent = true, buffer = true } },
        { "v", "T", ":<c-u>call v:lua.G_vaddPairs(\"try {\", \"} catch (e: any) {}\")<cr>", { noremap = true, silent = true, buffer = true } },
    })
end

local function _python()
    G.map({ { "v", "D", ":<c-u>call v:lua.G_vaddPairs(\"/** \", \" */\")<cr>", { noremap = true, silent = true, buffer = true } }, })
end

local function _vue()
    G.api.nvim_create_autocmd({ "BufWritePre" }, { buffer = 0, command = "call CocAction('format')" })
    G.map({ { "v", "D", ":<c-u>call v:lua.G_vaddPairs(\"<!--\", \"--> \")<cr>", { noremap = true, silent = true, buffer = true } }, })
end

local function _markdown()
    G.hi({
        ["MDTodoDate"] = { fg = "#5faf5f", italic = false }, -- 71
        ["MDDoneDate"] = { fg = "#5faf5f", italic = true, strikethrough = true }, -- 71
        ["MDTodoText"] = { italic = false },
        ["MDDoneText"] = { fg = "#00afaf", italic = true, strikethrough = true }, -- 37
        ["MDDeadline"] = { fg = "#d70087", bold = true, underline = true }, -- 162
        ["MDNearline"] = { fg = "#d7af00", bold = true }, -- 178
    })
    G.cmd([[
        call matchadd('MDDeadline', 'D:'.strftime("%Y-%m-%d"))
        call matchadd('MDNearline', 'D:'.strftime("%Y-%m-%d", localtime() + 3600 * 24))
        call matchadd('MDNearline', 'D:'.strftime("%Y-%m-%d", localtime() + 3600 * 48))
    ]])
    G.map({
        { "n", "<cr>", ":call v:lua.G_markdown_toggleCheck(0)<cr><cr>", { noremap = true, silent = true, buffer = true } },
        { "n", "<2-LeftMouse>", ":call v:lua.G_markdown_toggleCheck(1)<cr><2-LeftMouse>", { noremap = true, silent = true, buffer = true } },
        { "v", "B", ':<c-u>call v:lua.G_vaddPairs("**", "**")<cr>', { noremap = true, silent = true, buffer = true } },
        { "v", "I", ':<c-u>call v:lua.G_vaddPairs("*", "*")<cr>', { noremap = true, silent = true, buffer = true } },
        { "v", "T", ':<c-u>call v:lua.G_vaddPairs("- [ ] ", "")<cr>', { noremap = true, silent = true, buffer = true } },
        { "v", "`", ':<c-u>call v:lua.G_vaddPairs("`", "``")<cr>', { noremap = true, silent = true, buffer = true } },
        { "v", "C", ':<c-u>call v:lua.G_vaddPairs("```plaintext", "```")<cr>', { noremap = true, silent = true, buffer = true } },
    })
    G.cmd("call timer_start(0, 'v:lua.G_markdown_loadafter')") -- 延迟加载
end

local map = {
    go = _go,
    typescript = _typescript,
    javascript = _javascript,
    vue = _vue,
    python = _python,
    markdown = _markdown,
}

for filetype, func in pairs(map) do
    G.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { filetype },
        callback = function ()
            if G.b.loaded == 1 then return end; G.b.loaded = 1
            func()
        end
    })
end

-- 部分需要暴露到全局的函数

function G_markdown_loadafter()
    G.cmd([[syn match markdownError "\w\@<=\w\@="]])
    G.cmd([[syn match MDDoneDate /[SD]:\d\{4\}\([\/-]\d\d\)\{2\}/ contained]])
    G.cmd([[syn match MDTodoDate /[SD]:\d\{4\}\([\/-]\d\d\)\{2\}/ contained]])
    G.cmd([[syn match MDDoneText /\zs.*- \[x\] \zs.*/ contains=MDDoneDate contained]])
    G.cmd([[syn match MDTodoText /- \[ \] \zs.*/ contains=MDTodoDate contained]])
    G.cmd([[syn match MDTask /\zs.*- \[\(x\| \)\] .*/ contains=MDDoneText,MDTodoText]])
    G.cmd([[
        let b:md_block = '```'
        setlocal shiftwidth=2
        setlocal softtabstop=2
        setlocal tabstop=2
    ]])
end

function G_markdown_toggleCheck(needsave)
    local line = G.fn.getline('.')
    if line:match('^%s*- %[ %]') then line = line:gsub('%[ %]', '[x]')
    elseif line:match('^%s*- %[x%]') then line = line:gsub('%[x%]', '[ ]')
    else return end
    G.fn.setline('.', line)
    if needsave then G.cmd('w') end
end
