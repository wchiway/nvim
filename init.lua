-- 性能优化：启用 Lua 模块加载器
if vim.loader then
    vim.loader.enable()
end

-- 性能优化：禁用不必要的内置插件和 Provider
local builtins = {
    "gzip",
    "zip",
    "zipPlugin",
    "fzf",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "matchit",
    "matchparen",
    "logiPat",
    "rrhelper",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "tohtml",
    "tutor",
}

for _, plugin in ipairs(builtins) do
    vim.g["loaded_" .. plugin] = 1
end

-- 禁用不需要的语言提供者
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0 -- 禁用 Python 2
vim.g.loaded_python3_provider = 0 -- 禁用 Python 3

require('profile')  -- 基础配置
require('packinit') -- 插件配置
require('keymap')   -- 按键配置
require('autocmd')  -- 自动命令配置
