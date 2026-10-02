local toggle = require('loader.toggle')
local color = require('loader.colors')

return {
  'nvim-lualine/lualine.nvim',
  enabled = toggle.lualine,
  event = "UIEnter",
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  config = function ()
    local common = {
      b = { fg = color.white, bg = color.grey },
      c = { fg = color.white, bg = color.black },
      x = { fg = color.white, bg = color.black },
      y = { fg = color.white, bg = color.dark },
      z = { fg = color.white, bg = color.dark },
    }

    local bubbles_theme = {
      normal = vim.tbl_extend("force", common, {
        a = { fg = color.black, bg = color.red, gui = "bold" },
      }),

      insert = vim.tbl_extend("force", common, {
        a = { fg = color.black, bg = color.blue, gui = "bold" },
      }),

      visual = vim.tbl_extend("force", common, {
        a = { fg = color.black, bg = color.cyan, gui = "bold" },
      }),

      command = vim.tbl_extend("force", common, {
        a = { fg = color.black, bg = color.green, gui = "bold" },
      }),

      replace = vim.tbl_extend("force", common, {
        a = { fg = color.black, bg = color.white, gui = "bold" },
      }),

      terminal = vim.tbl_extend("force", common, {
        a = { fg = color.black, bg = color.violet, gui = "bold" },
      }),

      inactive = vim.tbl_extend("force", common, {
        a = { fg = color.black, bg = color.violet, gui = "bold" },
      }),
    }

    require("lualine").setup({
      options = {
        theme = bubbles_theme,
        globalstatus = true,

        component_separators = "",
        section_separators = "",

        disabled_filetypes = {
          statusline = { "NvimTree" },
        },
      },

      sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              return str:sub(1, 1):upper()
            end,
          },
        },

        lualine_b = {
          {
            "filename",
            path = 0,
            color = {
              bg = color.black,
            },
          },
        },

        lualine_c = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            update_in_insert = true,

            sections = { "error", "warn" },

            symbols = {
              error = "",
              warn  = "",
            },

            diagnostics_color = {
              error = { fg = color.cherry },
              warn  = { fg = color.yellow },
            },

            color = {
              bg = color.black;
            },
          },
        },

        lualine_x = {},

        lualine_y = {},

        lualine_z = {
          {
            "branch",
            color = {
              fg = color.black,
              bg = color.green,
            }
          },
        },
      },

      inactive_sections = {
        lualine_a = { "filename" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },

      tabline = {},
      extensions = {},
    })
  end
}
