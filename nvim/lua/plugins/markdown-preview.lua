return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  -- Built-in installer (prebuilt binary into gitignored app/bin/) instead of
  -- `npm install`, which rewrites the tracked app/yarn.lock and makes
  -- lazy.nvim refuse to update the plugin on every launch.
  build = function()
    -- lazy.load first: the plugin is lazy-loaded, so its autoload/ isn't on
    -- runtimepath when build runs.
    require("lazy").load({ plugins = { "markdown-preview.nvim" } })
    vim.fn["mkdp#util#install"]()
  end,
  init = function()
    -- Always echo the URL so it can be copied into a browser. Printing
    -- the URL with "localhost" (not the remote hostname) means a tunneled
    -- port via ssh-autoforward works by pasting the line as-is.
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_open_ip = "localhost"
    -- Only on headless SSH sessions, replace the browser-opener with a
    -- no-op so the plugin doesn't throw "can't open browser" errors.
    -- Local nvim still uses the real default browser.
    if vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil then
      vim.g.mkdp_browser = "true"
    end
  end,
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
  },
}
