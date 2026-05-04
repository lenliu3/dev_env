return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '▎' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
          vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
          vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Undo stage hunk' })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
          vim.keymap.set('n', '<leader>hb', gs.blame_line, { buffer = bufnr, desc = 'Blame line' })
          vim.keymap.set('n', '<leader>hd', gs.toggle_linehl, { buffer = bufnr, desc = 'Toggle diff overlay' })
        end,
      })
    end,
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "lewis6991/satellite.nvim",
    config = function()
      require('satellite').setup({
        excluded_filetypes = { "NvimTree" },
      })
    end,
  },
}
