
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },

    keys = {
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Start / Continue",
      },
      {
        "<F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(
            vim.fn.input("Breakpoint condition: ")
          )
        end,
        desc = "Debug: Conditional Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Continue",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug: Open REPL",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: Toggle UI",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: Terminate",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Debug: Run Last",
      },
    },

    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dap.defaults.fallback.terminal_win_cmd = "belowright 12split"

      require("mason").setup()

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb" },
        automatic_installation = true,
      })

      dapui.setup({
        icons = {
          expanded = "▾",
          collapsed = "▸",
          current_frame = "▸",
        },

        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "↳",
            step_over = "↷",
            step_out = "↰",
            step_back = "←",
            run_last = "↻",
            terminate = "■",
            disconnect = "⏏",
          },
        },

        layouts = {
          {
            elements = {
              {
                id = "scopes",
                size = 0.40,
              },
              {
                id = "breakpoints",
                size = 0.20,
              },
              {
                id = "stacks",
                size = 0.25,
              },
              {
                id = "watches",
                size = 0.15,
              },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              {
                id = "repl",
                size = 0.55,
              },
              {
                id = "console",
                size = 0.45,
              },
            },
            size = 10,
            position = "bottom",
          },
        },

        floating = {
          border = "rounded",
          max_height = 0.9,
          max_width = 0.9,
        },

        windows = {
          indent = 1,
        },
      })

      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = "eol",
      })

      -- CodeLLDB adapter installed by Mason.
      local codelldb =
      vim.fn.stdpath("data") .. "/mason/bin/codelldb"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb,
          args = { "--port", "${port}" },
        },
      }

      -- Compile the current C++ file and launch it.
      local function build_cpp()
        local source = vim.api.nvim_buf_get_name(0)

        if source == "" or not source:match("%.cpp$") then
          vim.notify(
            "Open a saved .cpp file first",
            vim.log.levels.ERROR
          )
          return nil
        end

        local output = source:gsub("%.cpp$", ".out")

        vim.cmd("silent! update")

        local command = {
          "g++",
          "-g",
          "-O0",
          "-std=c++17",
          source,
          "-o",
          output,
        }

        local result = vim.fn.system(command)

        if vim.v.shell_error ~= 0 then
          vim.notify(
            "C++ compilation failed:\n" .. result,
            vim.log.levels.ERROR
          )
          return nil
        end

        return output
      end

      dap.configurations.cpp = {
        {
          name = "C++: Build and Debug",
          type = "codelldb",
          request = "launch",

          program = function()
            return build_cpp()
          end,

          cwd = function()
            return vim.fn.expand("%:p:h")
          end,

          stopOnEntry = false,
          args = {},

          -- Show the program's stdin/stdout in a terminal.
          runInTerminal = true,
          console = "integratedTerminal",
        },
      }

      dap.configurations.c = dap.configurations.cpp

      dap.configurations.c = dap.configurations.cpp

      -- Automatically open and close the debugger UI.
      dap.listeners.after.event_initialized["dapui_config"] =
      function()
        dapui.open()
      end

      dap.listeners.before.event_terminated["dapui_config"] =
      function()
        dapui.close()
      end

      dap.listeners.before.event_exited["dapui_config"] =
      function()
        dapui.close()
      end

      dap.listeners.before.disconnect["dapui_config"] =
      function()
        dapui.close()
      end

      -- Fix terminal output not refreshing until window resize.
      local function refresh_dap_terminal()
        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)

            if vim.bo[buf].buftype == "terminal" then
              vim.api.nvim_win_call(win, function()
                vim.cmd("redraw")
              end)
            end
          end
        end)
      end

      dap.listeners.after.event_initialized["terminal_redraw"] =
      refresh_dap_terminal

      dap.listeners.after.event_stopped["terminal_redraw"] =
      refresh_dap_terminal

      dap.listeners.after.event_continued["terminal_redraw"] =
      refresh_dap_terminal

      -- Breakpoint signs.
      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DiagnosticError",
      })

      vim.fn.sign_define("DapBreakpointCondition", {
        text = "◆",
        texthl = "DiagnosticWarn",
      })

      vim.fn.sign_define("DapStopped", {
        text = "▶",
        texthl = "DiagnosticInfo",
        linehl = "Visual",
      })

      vim.fn.sign_define("DapLogPoint", {
        text = "◆",
        texthl = "DiagnosticInfo",
      })
    end,
  },
}
