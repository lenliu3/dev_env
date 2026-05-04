return {
  "rmagatti/auto-session",
  opts = {
    auto_restore = true,
    auto_save = true,
    pre_save_cmds = { "NvimTreeClose" },
    suppressed_dirs = { "~/", "~/Downloads" },
    bypass_save_filetypes = { "NvimTree" },
    cwd_change_handling = true,
  },
}
