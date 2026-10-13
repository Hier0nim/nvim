-- Native runtime configuration: EasyDotnet merges these protocol settings.
return {
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        -- Neovim does the watching; see the libuv watcher override in lua/config/lsp.lua.
        dynamicRegistration = true,
      },
    },
  },
  settings = {
    ['csharp|code_lens'] = { dotnet_enable_tests_code_lens = false },
  },
}
