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
          }
          return opts
        end,
      },
    },
    opts = function(_, opts)
      local utils = require 'nixCatsUtils'
      local cmd = {}

      if utils.isNixCats then
        -- Nix environment
        local rzls = vim.fn.get_nix_store 'rzls'

        vim.list_extend(cmd, {
          'Microsoft.CodeAnalysis.LanguageServer',
          '--stdio',
          '--logLevel=Information',
          '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
          '--razorSourceGenerator=' .. vim.fs.joinpath(rzls, 'Microsoft.CodeAnalysis.Razor.Compiler.dll'),
          '--razorDesignTimePath=' .. vim.fs.joinpath(rzls, 'Targets', 'Microsoft.NET.Sdk.Razor.DesignTime.targets'),
          '--extension',
          vim.fs.joinpath(rzls, 'RazorExtension', 'Microsoft.VisualStudioCode.RazorExtension.dll'),
        })
      else
        -- Non-nix: use Mason registry
        local mason_registry = require 'mason-registry'

        if mason_registry.get_package('roslyn'):is_installed() then
          vim.list_extend(cmd, {
            'roslyn',
            '--stdio',
            '--logLevel=Information',
            '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
          })

          local rzls_pkg = mason_registry.get_package 'rzls'
          if rzls_pkg:is_installed() then
            local rzls_path = vim.fn.expand '$MASON/packages/rzls/libexec'
            table.insert(cmd, '--razorSourceGenerator=' .. vim.fs.joinpath(rzls_path, 'Microsoft.CodeAnalysis.Razor.Compiler.dll'))
            table.insert(cmd, '--razorDesignTimePath=' .. vim.fs.joinpath(rzls_path, 'Targets', 'Microsoft.NET.Sdk.Razor.DesignTime.targets'))
            vim.list_extend(cmd, {
              '--extension',
              vim.fs.joinpath(rzls_path, 'RazorExtension', 'Microsoft.VisualStudioCode.RazorExtension.dll'),
            })
          end
        end
      end
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
  {
    'GustavEikaas/easy-dotnet.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'folke/snacks.nvim' },
    opts = {
      picker = 'snacks',
    },
  },
}
