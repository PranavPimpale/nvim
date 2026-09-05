local colors = require('loader.colors')
local api = vim.api

api.nvim_create_autocmd("FileType", {
  pattern = {"lua", "python", "html", "javascript", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd("echo ''")
    end, 500)
  end,
})

-- notification on save of file
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(args)
    local filename = vim.fn.fnamemodify(args.file, ":t")
    local text = " Saved: " .. filename .. " "

    local width = vim.fn.strdisplaywidth(text)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })

    local win = vim.api.nvim_open_win(buf, false, {
      relative = "editor",
      row = 0,
      col = vim.o.columns - width - 1,
      width = width,
      height = 1,
      style = "minimal",
      border = "rounded",
    })

    vim.defer_fn(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end

      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end, 1000)
  end,
})

-- restore cursor to file position in previous editing session
api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local mark = api.nvim_buf_get_mark(args.buf, '"')
    local line_count = api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      api.nvim_win_set_cursor(0, mark)
      -- defer centering slightly so it's applied after render
      vim.schedule(function()
        vim.cmd("normal! zz")
      end)
    end
  end,
})

-- no auto continue comments on new line
api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("no_auto_comment", {}),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- highlight yank
api.nvim_create_autocmd("TextYankPost", {
  group = api.nvim_create_augroup("highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function()
    vim.highlight.on_yank({ timeout = 200, visual = true })
  end,
})

-- open help in vertical split
api.nvim_create_autocmd("FileType", {
  pattern = "help",
  command = "wincmd L",
})

-- auto resize splits when the terminal's window is resized
api.nvim_create_autocmd("VimResized", {
  command = "wincmd =",
})

-- remove trailing spaces after saving
api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local view = vim.fn.winsaveview()

    vim.cmd([[%s/\s\+$//e]])

    vim.fn.winrestview(view)
  end,
})

-- Fix multiple blank lines to a single blank line
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local has_extra = false

    for i = 2, #lines do
      if lines[i] == "" and lines[i - 1] == "" then
        has_extra = true
        break
      end
    end

    if not has_extra then
      return
    end

    local result = {}
    local blank = false

    for _, line in ipairs(lines) do
      if line == "" then
        if not blank then
          table.insert(result, "")
        end
        blank = true
      else
        table.insert(result, line)
        blank = false
      end
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
  end,
})

-- removes all blank lines below the end of the file
local function remove_trailing_blank_lines()
  local last = vim.fn.line("$")

  while last > 0 and vim.fn.getline(last):match("^%s*$") do
    vim.fn.deletebufline(0, last)
    last = last - 1
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = remove_trailing_blank_lines,
})

-- permanent bold/italic disabled
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Strip bold and italic from all highlight groups",
  callback = function()
    for _, group in ipairs(vim.fn.getcompletion("", "highlight")) do
      local hl = vim.api.nvim_get_hl(0, { name = group })
      if hl.bold or hl.italic then
        hl.bold = false
        hl.italic = false
        vim.api.nvim_set_hl(0, group, hl)
      end
    end
  end,
})

------ [THEME SETTINGS] ------

-- transparent background, no matter what theme
local transparent_groups = {
  -- core
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "SignColumn",
  "FoldColumn",
  "EndOfBuffer",
  "WinSeparator",
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "TabLineFill",

  -- Popup menu
  "Pmenu",
  "PmenuSbar",
  "PmenuThumb",

  -- Telescope
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopePromptBorder",
  "TelescopePromptTitle",
  "TelescopeResultsNormal",
  "TelescopeResultsBorder",
  "TelescopeResultsTitle",
  "TelescopePreviewNormal",
  "TelescopePreviewBorder",
  "TelescopePreviewTitle",

  -- cmp
  "CmpDocumentation",
  "CmpDocumentationBorder",
  "BlinkCmpMenu",
  "BlinkCmpMenuBorder",
}

local function transparent_bg()
  for _, group in ipairs(transparent_groups) do
    pcall(api.nvim_set_hl, 0, group, {
      bg = "NONE",
      ctermbg = "NONE",
    })
  end
end

-- All personal highlight overrides
local function global_highlights()
  transparent_bg()

  -- Cursor line
  api.nvim_set_hl(0, "CursorLine", { bg = colors.line })

  -- Search
  api.nvim_set_hl(0, "Search", { bg = colors.search })
  api.nvim_set_hl(0, "IncSearch", { bg = colors.incsearch })

  -- Matching Parenthesis
  api.nvim_set_hl(0, "MatchParen", {
    fg = colors.parenthesis,
    bg = colors.grey,
    bold = true,
  })

  -- telescope cursor line
  api.nvim_set_hl(0, "TelescopeSelection", { bg = colors.select })

  -- cmp.nvim coloring stuffs
  api.nvim_set_hl(0, "CmpSel", { fg = nil, bg = colors.select })
  api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.comment, bold = true })
  api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.comment, bold = true })
  api.nvim_set_hl(0, "CmpItemAbbr", { fg = colors.itemAbbr })
  api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.itemMenu })
  api.nvim_set_hl(0, "CmpItemKind", { fg = colors.dark })
end

global_highlights()

api.nvim_create_autocmd("ColorScheme", {
  callback = global_highlights,
})
