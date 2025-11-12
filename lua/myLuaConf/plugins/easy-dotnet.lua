return {
  {
    'easy-dotnet.nvim',
    ft = { 'cs', 'csproj', 'sln', 'slnx', 'slnf' },
    after = function()
      require('easy-dotnet').setup()
    end,
  },
}
