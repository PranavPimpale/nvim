
local api = vim.api
local fn = vim.fn

local ns = api.nvim_create_namespace("search_count")
local group = api.nvim_create_augroup("SearchCounter", { clear = true })

local update_id = 0
local delay = 30

local function set_counter_hl()
  api.nvim_set_hl(0, "CounterStuff", {
    fg = "#000000",
    bg = "#f1fa8c",
  })
end

set_counter_hl()

api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = set_counter_hl,
})

local function clear_search_count(buf)
  buf = buf or api.nvim_get_current_buf()

  if api.nvim_buf_is_valid(buf) then
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
end

local function update_search_count()
  local buf = api.nvim_get_current_buf()

  clear_search_count(buf)

  if vim.bo[buf].buftype ~= "" or vim.v.hlsearch == 0 then
    return
  end

  local pattern = fn.getreg("/")

  if pattern == "" then
    return
  end

  local ok, count = pcall(fn.searchcount, {
    recompute = 1,
    maxcount = 9999,
    timeout = 100,
  })

  if not ok or not count or count.total == 0 then
    return
  end

  local match_ok, match = pcall(fn.searchpos, pattern, "cnW")

  if not match_ok or not match or match[1] == 0 then
    return
  end

  local cursor = api.nvim_win_get_cursor(0)

  if cursor[1] ~= match[1] then
    return
  end

  api.nvim_buf_set_extmark(buf, ns, match[1] - 1, 0, {
    virt_text = {
      {
        string.format("[%d/%d]", count.current, count.total),
        "CounterStuff",
      },
    },
    virt_text_pos = "eol",
  })
end

local function schedule_update()
  update_id = update_id + 1
  local id = update_id

  vim.defer_fn(function()
    if id == update_id then
      update_search_count()
    end
  end, delay)
end

api.nvim_create_autocmd({
  "CursorMoved",
  "CmdlineLeave",
  "BufEnter",
  "SearchWrapped",
}, {
    group = group,
    callback = schedule_update,
  })

api.nvim_create_autocmd("CmdlineEnter", {
  group = group,
  callback = function()
    update_id = update_id + 1
    clear_search_count()
  end,
})

api.nvim_create_autocmd("OptionSet", {
  group = group,
  pattern = "hlsearch",
  callback = function()
    if vim.v.hlsearch == 0 then
      update_id = update_id + 1
      clear_search_count()
    else
      schedule_update()
    end
  end,
})

api.nvim_create_autocmd("BufLeave", {
  group = group,
  callback = function(ev)
    clear_search_count(ev.buf)
  end,
})

