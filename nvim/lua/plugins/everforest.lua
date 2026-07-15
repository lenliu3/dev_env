return {
  "neanias/everforest-nvim",
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    require("everforest").setup({
      background = "soft",
    })
    -- Configured but not loaded at startup; kanagawa-wave is the active theme.
    -- Switch back any time with `:colorscheme everforest`.
  end,
}
