local term_buf = nil
local term_win = nil
local width = 100
local height = 20

local function create_terminal()
  local row = math.floor((vim.o.lines - height) / 2) - 2
  local col = math.floor((vim.o.columns - width) / 2)

  term_buf = vim.api.nvim_create_buf(false, true)

  local current_file = vim.fn.expand("%:t")
  vim.api.nvim_buf_set_name(term_buf, "[Term] " .. current_file)

  term_win = vim.api.nvim_open_win(term_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
  })

  vim.fn.termopen(vim.o.shell, {
    cwd = vim.fn.expand("%:p:h"),
  })

  vim.cmd("startinsert")
end

local function toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    return
  end

  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local row = math.floor((vim.o.lines - height) / 2) - 2
    local col = math.floor((vim.o.columns - width) / 2)

    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      border = "rounded",
    })

    vim.cmd("startinsert")
  else
    create_terminal()
  end
end

local function kill_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
  end

  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_buf_delete(term_buf, { force = true })
  end

  term_buf = nil
  term_win = nil
end

vim.keymap.set({ "n", "t" }, "<C-k>", toggle_terminal, { silent = true })
vim.keymap.set({ "n", "t" }, "<C-d>", kill_terminal, { silent = true })

vim.keymap.set("t", "<Esc>", function()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
  end
end, { silent = true })

-- in terminal mode <C-n> enters normal mode, pressing "i" enters insert mode
vim.keymap.set("t", "<C-n>", [[<C-\><C-n>]], { silent = true })
