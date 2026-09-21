![nvimyes](https://readme-typing-svg.demolab.com?font=Fira+Code&size=30&pause=1000&color=000000&vCenter=true&width=435&height=45&lines=NVIM+YES)

---

基于 [yaocccc/nvim](https://github.com/yaocccc/nvim) 精简而来的个人配置，定位是**单文件编辑器**而非项目 IDE。
运行环境 Neovim 0.12.5（mise 安装），6 个插件，冷启动约 25ms。

* [如何使用](#如何使用)
* [配置结构](#配置结构)
* [全局快捷键](#全局快捷键)
* [插件与键位](#插件与键位)

## 如何使用

1. 将项目 clone 至 `~/.config/nvim`（注意备份自己的配置）
2. 启动 nvim，lazy.nvim 与所有插件自动安装
3. 每次修改过 `lua/packinit.lua` 后重启并执行 `:Lazy sync`

外部依赖：`git`（lazy.nvim）、`node`（coc.nvim）、C 编译器（tree-sitter parser）。

## 配置结构

```
.
├─ init.lua            -- 入口: 禁用内置插件/provider, 按序加载 lua/ 下模块
├─ coc-settings.json   -- coc 配置
├─ snippets/           -- coc-snippets 代码片段
└─ lua/
   ├─ G.lua            -- 封装 vim.* 与 map/hi/cmd 等通用方法
   ├─ profile.lua      -- 各种 set 选项
   ├─ keymap.lua       -- 全局快捷键
   ├─ autocmd.lua      -- 自动命令与按文件类型的设置
   ├─ packinit.lua     -- lazy.nvim 插件列表
   └─ pack/            -- 每个插件一个配置模块 (config 在加载前, setup 在加载后)
```

## 全局快捷键

| 模式   | 键                   | 说明                              |
| ------ | --------             | ---------                         |
| normal | ;                    | :                                 |
| normal | +  /  _              | 数字自增 / 自减                   |
| normal | ,                    | 重复宏 q                          |
| normal | \                    | 清除搜索高亮                      |
| normal | \w                   | 开启/关闭 wrap                    |
| normal | backspace            | 删除当前词并插入                  |
| normal | ctrl + j             | 从 , 处打断当前行                 |
| insert | ctrl + h             | 删除到词首                        |
| insert | ctrl + a / ctrl + e  | 行首 / 行尾                       |
| command| ctrl + a / ctrl + e  | Home / End                        |
| all    | ctrl + s             | 进入替换模式                      |
| normal | S  /  W  /  Q        | 保存(自动建目录) / 关闭 buffer / 强制退出 |
| normal | R                    | 保存并重载 buffer, 刷新高亮       |
| visual | > / tab  < / s-tab   | 缩进 / 反缩进                     |
| all    | shift + 方向         | 选中文本                          |
| all    | ctrl + shift + 方向  | 快速移动 (10 行 / 行首尾)         |
| all    | ctrl + u             | 清空本行                          |
| all    | alt + up / down      | 上下移动当前行或选中块            |
| all    | alt + o / alt + O    | 下方 / 上方新起一行               |
| normal | alt + a              | 全选                              |
| normal | sv / sp              | 左右 / 上下分屏                   |
| normal | sc / so              | 关闭当前 / 关闭其他窗口           |
| normal | s + 方向             | 聚焦对应窗口                      |
| normal | ctrl + space         | 切换窗口                          |
| normal | s=  alt+,  alt+.     | 窗口等宽 / 减小 / 增大            |
| normal | ss  alt+left/right   | 切换 buffer                       |
| normal | tt                   | 底部打开 10 行终端                |
| normal | -                    | 折叠 / 展开                       |
| visual | -                    | 折叠选中内容                      |
| normal | space                | 在行首 / 首个非空字符 / 行尾跳转  |
| normal | 0                    | 跳转到匹配括号 (%)                |
| visual | t / T                | 驼峰与下划线互转 (T 首字母大写)   |
| visual | ( [ { " ' `          | 用对应符号包裹选中内容            |

## 插件与键位

### neoclide/coc.nvim -- LSP / 补全

扩展列表在 `lua/pack/coc.lua` 的 `coc_global_extensions`。

| 模式   | 键        | 说明                       |
| ------ | --------  | ---------                  |
| normal | gd gy gi gr | 定义 / 类型 / 实现 / 引用 |
| normal | K         | 文档                       |
| normal | F2        | 重命名                     |
| normal | F3 / F4   | 重启 coc / 开关 coc        |
| normal | F9        | 编辑当前文件类型 snippet   |
| normal | ctrl + e  | 诊断列表                   |
| normal | =         | 格式化 (visual 下格式化选中) |
| normal | mm        | 翻译当前词 (coc-translator) |
| normal | ( / )     | 上 / 下一处 git 修改 (coc-git) |
| normal | C         | 当前行提交信息 (coc-git)   |
| normal | \g        | 开关 git blame 虚拟文本    |
| visual | if af ic ac | 选中函数 / 类 内部或整体 |
| insert | tab / s-tab | 补全上下选择             |

### nvim-mini/mini.nvim -- surround / 自动配对 / 缩进线 / 关键字高亮 / 状态栏

| 模式   | 键        | 说明                              |
| ------ | --------  | ---------                         |
| normal | ys{motion}{char} | 添加包裹, 如 `ysiw"`       |
| normal | ds{char}  | 删除包裹, 如 `ds"`                |
| normal | cs{old}{new} | 替换包裹, 如 `cs"'`            |
| normal | ??        | 行注释 (内置 gc)                  |
| visual | /         | 注释选中行                        |

自动高亮 `TODO` `NOTE` `FIXME` `HACK` 与 `#rrggbb` 颜色值。

### nvim-treesitter/nvim-treesitter -- 语法高亮

固定在归档的 `v0.10.0`（对应 Neovim 0.10）。parser 列表在 `lua/pack/tree-sitter.lua` 的 `ensure_installed`，不会自动安装陌生语言。

### 其他

| 插件 | 用途 | 键位 |
| --- | --- | --- |
| terryma/vim-expand-region | 扩大 / 缩小选区 | visual `v` / `V` |
| Mr-LLLLL/interestingwords.nvim | 高亮光标下的词 | `ff` 高亮 / `FF` 清除全部 |
| ThorstenRhau/token | 配色方案 | |

命令行 `:` `/` `?` 边输入边弹出补全菜单为 Neovim 0.12 内置功能（`wildtrigger()`），`tab` 或上下键选择，菜单未弹出时上下键翻历史。

### 按文件类型的额外键位 (`lua/autocmd.lua`)

| 文件类型 | 模式 | 键 | 说明 |
| --- | --- | --- | --- |
| go / js / ts / py | visual | D | 包裹为 `/** */` 注释 |
| js / ts | visual | T | 包裹为 try/catch |
| vue | visual | D | 包裹为 `<!-- -->` |
| go / vue | | 保存时 | 自动格式化 (go 另加整理 import) |
| markdown | normal | enter / 双击 | 切换 `- [ ]` 复选框 |
| markdown | visual | B / I / ` / C / T | 加粗 / 斜体 / 行内代码 / 代码块 / 待办项 |
