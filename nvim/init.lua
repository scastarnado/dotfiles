vim.o.number = true -- show line numbers
vim.o.ignorecase = true -- when searching, do not consider upper case
vim.o.hlsearch = false -- do not highlight past searches
vim.o.wrap = true -- long lines are always completely visible
vim.o.breakindent = true -- keep indentation that are "changed" when wrap acts
vim.o.tabstop = 2 -- use two characters when tabbing
vim.o.shiftwidth = 2 -- value that nvim uses to indent a line
vim.o.expandtab = true -- transform tabs into spaces

vim.g.mapleader = ' ' -- set the leader key to space

vim.keymap.set({'n', 'x'}, 'gy', '"y') -- copy to clipboard
vim.keymap.set({'n', 'x'}, 'gp', '"+p') -- paste from clipboard
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<CR>') -- select all text with leader+a
