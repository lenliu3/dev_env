return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("kanagawa").setup()
    -- Variants: kanagawa-wave (dark, active), kanagawa-dragon (darkest), kanagawa-lotus (light).
    vim.cmd("colorscheme kanagawa-wave")
  end,
}
