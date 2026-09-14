-- Native runtime configuration: EasyDotnet merges these protocol settings.
return {
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  settings = {
    ['csharp|code_lens'] = { dotnet_enable_tests_code_lens = false },
  },
}
