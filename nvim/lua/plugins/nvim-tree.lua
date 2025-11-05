return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup()
    vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
    vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFile<CR>', { desc = 'Find current file in tree' })
  end,
}
