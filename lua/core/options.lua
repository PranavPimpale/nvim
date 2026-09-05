local opt = vim.o

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

opt.autoindent = true

-- Line Display
opt.number = true
opt.cursorline = true
opt.relativenumber = true
opt.scrolloff = 3

-- Git Sign Column
opt.signcolumn = "yes"

-- Performance
opt.updatetime = 50
opt.timeoutlen = 225
opt.synmaxcol = 200

-- Persistent Undo
opt.swapfile = false
opt.backup = false
local undodir = os.getenv("HOME") .. "/.vim/undodir"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
opt.undodir = undodir
opt.undofile = true

-- Search
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- CMD Mode Display
opt.showmode = false

-- line wrap
opt.wrap = true
opt.linebreak = true

-- blank line "~" disabled
opt.fillchars = "eob: "
