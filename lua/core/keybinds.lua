local keymap = vim.keymap

vim.g.mapleader = " "
keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- window navigation
keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
keymap.set("n", "<C-k>", "<C-w>k", { silent = true })

-- switching between buffer tabs
keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true })
keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true })

-- Insert mode cursor movement with Ctrl/Alt + h/j/k/l
keymap.set('i', '<C-h>', '<Left>',  { noremap = true, silent = true })
keymap.set('i', '<C-j>', '<Down>',  { noremap = true, silent = true })
keymap.set('i', '<C-k>', '<Up>',    { noremap = true, silent = true })
keymap.set('i', '<C-l>', '<Right>', { noremap = true, silent = true })

-- disabling arrow keys of keyboard in nvim
keymap.set("n", "<Up>", "<Nop>")
keymap.set("n", "<Down>", "<Nop>")
keymap.set("n", "<Left>", "<Nop>")
keymap.set("n", "<Right>", "<Nop>")

keymap.set("i", "<Up>", "<Nop>")
keymap.set("i", "<Down>", "<Nop>")
keymap.set("i", "<Left>", "<Nop>")
keymap.set("i", "<Right>", "<Nop>")

-- [cmd] :restart
keymap.set('n', '<leader>re', ':restart<CR>', { noremap = true, silent = true })

-- [cmd] :Lazy
keymap.set('n', '<leader>l', ':Lazy<CR>', { noremap = true, silent = true })

-- [cmd] :redo
keymap.set('n', 'U', ':redo<CR>', { noremap = true, silent = true })

-- select whole file
keymap.set("n", "va", "ggVG", { silent = true, desc = "Select entire file" })

-- yank/paste to clipboard
keymap.set("v", "<leader>y", function()
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd('normal! "+y')
  vim.api.nvim_win_set_cursor(0, pos)
end, { silent = true, desc = "Yank to system clipboard" })

keymap.set({ "n", "v" }, "<leader>p", function()
  vim.cmd('normal! "+p')
  vim.cmd("normal! '[V']")
  vim.cmd("normal! =")
  vim.cmd("normal! ']$")
end, { silent = true, desc = "Paste and format" })

-- format file
keymap.set("n", "<leader>cf", function()
  local view = vim.fn.winsaveview()
  vim.cmd("silent! normal! gg=G")
  vim.fn.winrestview(view)
end, { desc = "Format/reindent buffer (gg=G), preserve cursor view" })

-- ctrl+c to clear the cmdline
keymap.set('n', '<C-c>', ':echo ""<CR>', { noremap = true, silent = true })

-- Alt+l to hit enter
keymap.set("i", "<M-l>", "<CR>", { noremap = true, silent = true, desc = "Alt+L -> Enter" })

-- Alt+j to hit backspace
keymap.set("i", "<M-j>", "<BS>", { noremap = true, silent = true, desc = "Alt+H -> Backspace" })

-- toggle :noh
keymap.set("n", "<leader>n", function()
  vim.o.hlsearch = not vim.o.hlsearch
end, { desc = "Toggle search highlight" })

-- better yanking
keymap.set("v", "y", function()
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("normal! y")
  vim.api.nvim_win_set_cursor(0, pos)
end, { silent = true })

-- better pasting
keymap.set("n", "p", "p`]")
keymap.set("n", "P", "P`]")
