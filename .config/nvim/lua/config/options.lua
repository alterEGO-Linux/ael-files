vim.g.mapleader = '-'
vim.g.maplocalleader = '-'
local o = vim.opt
o.cursorline = true
o.swapfile = false
o.colorcolumn = '80'
o.number = true
o.relativenumber = true
o.wrap = true
o.linebreak = true
o.showbreak = '[......]'
o.scrolloff = 8 -- old value was 999; change to 999 for permanent centering
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true
o.wildmenu = true
o.path:append('**')
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.shiftround = true
o.laststatus = 2
o.background = 'dark'
o.termguicolors = true
o.foldlevelstart = 99
o.foldtext = 'v:lua.require"config.functions".foldtext()'
o.statusline = ' BUFFER [%n] FILE [%{fnamemodify(expand("%"),":h:t")}/%t] INFO [%{&ft}/%{&fenc!=""?&fenc:&enc}/%{&ff}] %= ROW [%l/%L (%03p%%)] COL [%03c] %{v:lua.require"config.functions".status_flags()}'
if vim.fn.has('clipboard') == 1 then o.clipboard = 'unnamedplus' end
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25
