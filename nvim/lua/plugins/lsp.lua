return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
        },
      })
      
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focusable = false })
        end,
      })
      
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        end,
      })
      
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pylsp",
          "jdtls",
          "lua_ls",
          "ts_ls",
          "marksman",
        },
        automatic_installation = true,
        handlers = {
          function(server_name)
            -- jdtls is driven by nvim-jdtls (see plugins/java.lua), skip here
            if server_name ~= "jdtls" then
              require("lspconfig")[server_name].setup({ capabilities = capabilities })
            end
          end,
          ["pylsp"] = function()
            require("lspconfig").pylsp.setup({
              capabilities = capabilities,
              settings = {
                pylsp = {
                  plugins = {
                    pylsp_mypy = { enabled = true },
                    ruff = { enabled = true },
                    pycodestyle = { enabled = false },
                    pyflakes = { enabled = false },
                    mccabe = { enabled = false },
                    pydocstyle = { enabled = false },
                    autopep8 = { enabled = false },
                    yapf = { enabled = false },
                    flake8 = { enabled = false },
                  },
                },
              },
            })
          end,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
  },
}
