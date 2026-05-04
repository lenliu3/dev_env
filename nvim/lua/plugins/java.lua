-- Skip this generic setup when the work-only override is installed.
local work_java = vim.fn.stdpath("config") .. "/lua/plugins-work/java.lua"
if (vim.uv or vim.loop).fs_stat(work_java) then
  return {}
end

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local attach_jdtls = function()
        local default_config = require("lspconfig.configs.jdtls").default_config
        local cmd = default_config.cmd

        -- lombok support
        local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
        if vim.uv.fs_stat(lombok_jar) then
          table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
        end

        local root_dir = require("jdtls.setup").find_root({
          ".git", "mvnw", "gradlew", "pom.xml", "build.gradle",
        })

        vim.keymap.set("n", "<leader>co", require("jdtls").organize_imports, { desc = "Organize Imports" })

        require("jdtls").start_or_attach({
          cmd = cmd,
          root_dir = root_dir,
        })
      end

      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "java",
        callback = attach_jdtls,
      })

      attach_jdtls()
    end,
  },
}
