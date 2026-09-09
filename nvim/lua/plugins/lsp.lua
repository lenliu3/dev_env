return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
  },

  {
    "mason-org/mason-lspconfig.nvim",

    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },

    opts = {
      ensure_installed = {
        "pylsp",
        "jdtls",
        "lua_ls",
        "ts_ls",
        "marksman",
        "qmlls",
      },

      automatic_installation = true,
      automatic_enable = {
        exclude = {
          "jdtls",
        },
      },
    },

    config = function(_, opts)
      local capabilities =
        require("cmp_nvim_lsp").default_capabilities()

      -- Mason / Mason LSP config
      require("mason-lspconfig").setup(opts)

      -- Apply completion capabilities to all LSPs
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Quickshell's recommended QML configuration
      vim.lsp.config("qmlls", {
        cmd = {
          "qmlls",
          "-E",
        },
      })

      -- Diagnostics
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
        },
      })

      -- Show diagnostic popup on CursorHold
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, {
            focusable = false,
          })
        end,
      })

      -- LSP keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = {
            buffer = args.buf,
          }

          --Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

          -- Information
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

          -- Editing
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
}
