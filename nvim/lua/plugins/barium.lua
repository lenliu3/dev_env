return {
  {
    url = "ssh://git.amazon.com:2222/pkg/VimBrazilConfig",
    branch = "mainline",
    ft = "brazil-config",
    config = function()
      vim.filetype.add{
        filename = {
          ['Config'] = 'brazil-config',
          ['packageInfo'] = 'brazil-config',
        },
      }
      vim.lsp.config('barium', {
        cmd = { 'barium' },
        filetypes = { 'brazil-config' },
        root_dir = function(fname)
          return vim.fs.root(fname, { 'Config' })
        end,
      })
      vim.lsp.enable('barium')
    end,
  },
}
