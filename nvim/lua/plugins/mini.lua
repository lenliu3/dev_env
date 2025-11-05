return {
  {
    "echasnovski/mini.diff",
    config = function()
      require('mini.diff').setup({
        view = {
          style = 'sign',
          signs = { add = '▎', change = '▎', delete = '▎' },
        },
      })
      vim.keymap.set('n', '<leader>go', function() require('mini.diff').toggle_overlay() end, { desc = 'Toggle diff overlay' })
    end,
  },
  {
    "echasnovski/mini.cursorword",
    config = function()
      require("mini.cursorword").setup()
    end,
  },
  {
    "echasnovski/mini.map",
    config = function()
      local minimap = require("mini.map")
      minimap.setup({
        integrations = {
          minimap.gen_integration.diff(),
        },
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          if vim.bo.filetype == "NvimTree" then
            minimap.close()
          else
            minimap.open()
          end
        end,
      })
      vim.keymap.set('n', '<leader>mm', ':lua MiniMap.toggle()<CR>', { desc = 'Toggle minimap' })
    end,
  },
}
