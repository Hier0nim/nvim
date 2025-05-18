return {
  {
    'seblyng/roslyn.nvim',
    ft = { 'cs', 'razor' },
    dependencies = {
      {
        'tris203/rzls.nvim',
        opts = function(_, opts)
          opts = {
            path = require('nixCatsUtils').lazyAdd(nil, 'rzls'),
            capabilities = vim.lsp.protocol.make_client_capabilities(),
          }
          return opts
        end,
        dependencies = {
          {
            'neovim/nvim-lspconfig',
            servers = {
              rzls = {
                setup = {
                  rzls = function(_, opts) -- code
                    vim.notify 'rzls setup being called'
                    require('rzls').setup(opts)
                  end,
                },
              },
            },
          },
        },
      },
    },
    opts = function(_, opts)
      local utils = require 'nixCatsUtils'

      local roslyn = vim.fs.joinpath(vim.fn.stdpath 'data', 'roslyn')
      local rzls = utils.lazyAdd(vim.fs.joinpath(vim.fn.stdpath 'data', 'rzls'), vim.fn.get_nix_store 'rzls')

      local cmd = utils.lazyAdd({ 'dotnet', vim.fs.joinpath(roslyn, 'Microsoft.CodeAnalysis.LanguageServer.dll') }, { 'Microsoft.CodeAnalysis.LanguageServer' })
      vim.list_extend(cmd, {
        '--stdio',
        '--logLevel=Information',
        '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
        '--razorSourceGenerator=' .. vim.fs.joinpath(rzls, 'Microsoft.CodeAnalysis.Razor.Compiler.dll'),
        '--razorDesignTimePath=' .. vim.fs.joinpath(rzls, 'Targets', 'Microsoft.NET.Sdk.Razor.DesignTime.targets'),
        '--extension',
        vim.fs.joinpath(rzls, 'RazorExtension', 'Microsoft.VisualStudioCode.RazorExtension.dll'),
      })

      opts = {
        config = {
          cmd = cmd,
        },
        handlers = require 'rzls.roslyn_handlers',
        settings = {
          ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,

            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      }
      return opts
    end,
    init = function()
      vim.filetype.add {
        extension = {
          razor = 'razor',
          cshtml = 'razor',
        },
      }
    end,
  },
}
