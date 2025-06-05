local utils = require 'nixCatsUtils'
local has_mason, mreg = pcall(require, 'mason-registry')

-- safe check: true only if mason-registry loaded & pkg is_installed
local function has_pkg(name)
  if not has_mason then
    return false
  end
  local ok, pkg = pcall(mreg.get_package, name)
  return ok and pkg and pkg:is_installed()
end

-- honour the nixCats category  flag (default=false for non-nix)
-- if still false, but roslyn is installed under Mason, enable it
local enabled = utils.enableForCategory('dotnet', false) or has_pkg 'roslyn'
if not enabled then
  return {}
end

return {
  {
    -- 'jmederosalvarado/roslyn.nvim',
    'seblyng/roslyn.nvim',
    ft = { 'cs', 'razor' },
    dependencies = {
      {
        'tris203/rzls.nvim',
        config = function()
          require('rzls').setup {
            path = require('nixCatsUtils').lazyAdd(nil, vim.fn.get_nix_store('rzls', { force = true }) .. '/bin/rzls'),
          }
        end,
      },
    },
    config = function()
      local cmd = {}
      if utils.isNixCats then
        -- Nix environment
        local rzls = vim.fn.get_nix_store('rzls', { force = true })
        vim.list_extend(cmd, {
          'Microsoft.CodeAnalysis.LanguageServer',
          '--stdio',
          '--logLevel=Information',
          '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
          '--razorSourceGenerator=' .. vim.fs.joinpath(rzls .. '/lib/rzls', 'Microsoft.CodeAnalysis.Razor.Compiler.dll'),
          '--razorDesignTimePath=' .. vim.fs.joinpath(rzls .. '/lib/rzls', 'Targets', 'Microsoft.NET.Sdk.Razor.DesignTime.targets'),
          '--extension',
          vim.fs.joinpath(rzls, 'RazorExtension', 'Microsoft.VisualStudioCode.RazorExtension.dll'),
        })
      else
        if mreg.get_package('roslyn'):is_installed() then
          vim.list_extend(cmd, {
            'roslyn',
            '--stdio',
            '--logLevel=Information',
            '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
          })

          local rzls_pkg = mreg.get_package 'rzls'
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
      vim.lsp.config('roslyn', {
        cmd = cmd,
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
      })
      vim.lsp.enable 'roslyn'
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
