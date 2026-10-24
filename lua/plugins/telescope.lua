local toggle = require('loader.toggle')

return {
  {
    'nvim-telescope/telescope.nvim', version = '*',
    enabled = toggle.telescope,
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function ()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local builtin = require('telescope.builtin')

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<Esc>"] = actions.close,

              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,

              ["<C-h>"] = function()
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes("<Left>", true, false, true),
                  "n",
                  false
                )
              end,

              ["<C-l>"] = function()
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes("<Right>", true, false, true),
                  "n",
                  false
                )
              end,

              ["<C-u>"] = function()
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes("<C-u>", true, false, true),
                  "n",
                  false
                )
              end,

              ["<C-a>"] = function()
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes("<Home>", true, false, true),
                  "n",
                  false
                )
              end,

              ["<C-i>"] = function()
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes("<End>", true, false, true),
                  "n",
                  false
                )
              end,
            },
            n = {
              ["<Tab>"] = actions.move_selection_next,
              ["<S-Tab>"] = actions.move_selection_previous,
            },
          },
        },
      })

      telescope.load_extension("fzf")

      -- keymaps
      vim.keymap.set("n", "<leader>f", function()
        builtin.find_files({
          selection_caret = "➜ ",
        })
      end)

      vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Telescope live grep' })

      vim.keymap.set("n", "<leader>b", function()
        builtin.buffers({
          selection_caret = "➜ ",
        })
      end)

      vim.keymap.set('n', '<leader>he', builtin.help_tags, { desc = 'Telescope help tags' })
    end
  }
}
