return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { "package%-lock%.json" },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      telescope.load_extension("fzf")

      -- File Navigation
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find old files" })
      vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Find commands" })

      -- LSP Integration
      vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "LSP definitions" })
      vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "LSP references" })
      vim.keymap.set("n", "gi", builtin.lsp_implementations, { desc = "LSP implementations" })
      vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "LSP references" })
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "LSP symbols" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "LSP diagnostics" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "java", "typescript", "javascript", "tsx", "kotlin", "markdown", "markdown_inline" },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },
}
