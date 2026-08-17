return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function(plugin)
    local app = plugin.dir .. "/app"
    -- The prebuilt server binary from the built-in installer segfaults on
    -- glibc 2.34, and rpc#start_server() picks it over node whenever it is
    -- executable. Clear +x so startup falls through to the node path.
    for _, bin in ipairs(vim.fn.glob(app .. "/bin/markdown-preview-*", false, true)) do
      vim.fn.setfperm(bin, "rw-r--r--")
    end
    -- Versions pinned to the tracked app/yarn.lock: npm resolves
    -- @chemzqm/neovim ^5.7.9 up to 5.9.x, which swapped msgpack-lite for
    -- @chemzqm/msgpack-lite and breaks the shipped lib/app bundle.
    -- --no-save/--no-package-lock avoid dirtying the plugin repo, which would
    -- make lazy.nvim refuse to update it.
    vim.fn.system({
      "npm", "install", "--prefix", app,
      "--no-save", "--no-package-lock", "--no-audit", "--no-fund",
      "@chemzqm/neovim@5.7.9", "log4js@6.4.0", "socket.io@2.4.0", "tslib@1.9.3",
    })
    if vim.v.shell_error ~= 0 then
      error("markdown-preview: npm install failed")
    end
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
