local toggle = require('loader.toggle')

return {
  -- NOTE: treesitter CLI installation needed
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = toggle.treesitter,
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      local ensure_installed = {
        "cpp",
        "lua",
        "bash",
        "vim",
        "c",
        "python",
        "query",
        "vimdoc",
        "json",
        "gitignore",
        "markdown",
        -- "javascript",
        -- "typescript",
        -- "tsx",
        -- "go",
        -- "yaml",
        -- "html",
        -- "css",
        -- "http",
        -- "prisma",
        -- "svelte",
        -- "graphql",
        -- "dockerfile",
        -- "java",
        -- "rust",
        -- "ron",
      }

      local installed = treesitter.get_installed and treesitter.get_installed() or {}

      local to_install = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)

      if #to_install > 0 then
        treesitter.install(to_install)
      end

      -- Safe FileType autocmd for highlighting + indentation
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
          local buf = args.buf
          local ft = vim.bo[buf].filetype

          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return
          end

          -- start treesitter safely
          pcall(vim.treesitter.start, buf, lang)

          -- enable indentation (skip yaml/markdown)
          if ft ~= "yaml" and ft ~= "markdown" then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.bo[buf].smartindent = false
            vim.bo[buf].cindent = false
          end
        end,
      })

    end,
  },
  -- NOTE: js,ts,jsx,tsx Auto Close Tags
  {
    "windwp/nvim-ts-autotag",
    enabled = toggle.ts_autotag,
    ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,           -- Auto-close tags
          enable_rename = true,          -- Auto-rename pairs
          enable_close_on_slash = false, -- Disable auto-close on trailing `</`
        },
        per_filetype = {
          ["html"] = {
            enable_close = true,
          },
          ["typescriptreact"] = {
            enable_close = true,
          },
        },
      })
    end,
  },
}
