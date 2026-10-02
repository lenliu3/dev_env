return {
  "ellisonleao/glow.nvim",
  cmd = "Glow",
  opts = {
    -- Any non-empty glow_path skips the plugin's fallback installer, which
    -- fetches glow v1.5.1 and untars its LICENSE/README/completions into
    -- ~/.local/bin. A missing glow errors on :Glow instead (see install.sh).
    glow_path = "glow",
  },
  keys = {
    {
      "<leader>mp",
      function()
        -- The plugin's q/<Esc> close only its newest window, so keep at most
        -- one preview open (in any tab) rather than stacking floats.
        local here = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          -- Closing a tab's last split also closes its float, staling its id.
          if vim.api.nvim_win_is_valid(win)
            and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "glowpreview" then
            here = here or vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage()
            vim.api.nvim_win_close(win, true)
          end
        end
        if not here then
          vim.cmd("Glow")
        end
      end,
      desc = "Markdown Preview",
    },
  },
}
