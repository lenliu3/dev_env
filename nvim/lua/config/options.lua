-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Enable true color support
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Disable line wrap and enable horizontal scrolling
vim.opt.wrap = false
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 8

-- Keep cursor centered while scrolling
vim.opt.scrolloff = 10

-- Faster CursorHold for diagnostic popup (in ms)
vim.opt.updatetime = 250

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})
