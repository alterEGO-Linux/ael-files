local in_linux_tty = vim.env.TERM == "linux"

vim.opt.termguicolors = not in_linux_tty
vim.opt.background = "dark"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 4

vim.cmd.colorscheme("surface")
