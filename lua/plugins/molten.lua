local utils = require 'nixCatsUtils'
if not utils.enableForCategory('python', false) then
  return {}
end

return {
  'benlubas/molten-nvim',
  build = ':UpdateRemotePlugins',
  dependencies = {
    '3rd/image.nvim',
    {
      'quarto-dev/quarto-nvim',
      dependencies = {
        'jmbuhr/otter.nvim',
        'nvim-treesitter/nvim-treesitter',
        {
          'neovim/nvim-lspconfig',
          ft = { 'markdown' },
        },
      },
      config = function()
        require('quarto').setup {
          lspFeatures = {
            enabled = true,
            languages = { 'python' },
            chunks = 'all',
            diagnostics = { enabled = true, triggers = { 'BufWritePost' } },
            completion = { enabled = true },
          },
          codeRunner = {
            enabled = true,
            -- "molten", "slime", "iron" or <function>
            default_method = 'molten',
            -- filetype to runner
            -- Takes precedence over `default_method`
            ft_runners = {
              { python = 'molten' },
            },
            never_run = { 'yaml' }, -- filetypes which are never sent to a code runner
          },
        }
      end,
    },
    {
      'GCBallesteros/jupytext.nvim',
      config = function()
        require('jupytext').setup {
          style = 'markdown',
          output_extension = 'md',
          force_ft = 'markdown',
        }
      end,
    },
  },
  config = function()
    local map = vim.keymap.set

    map('n', '<localleader>e', ':MoltenEvaluateOperator<CR>', { desc = 'evaluate operator', silent = true })
    map('n', '<localleader>os', ':noautocmd MoltenEnterOutput<CR>', { desc = 'show/enter output', silent = true })
    map('n', '<localleader>rr', ':MoltenReevaluateCell<CR>', { desc = 're-eval cell', silent = true })
    map('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv', { desc = 'execute visual selection', silent = true })
    map('n', '<localleader>oh', ':MoltenHideOutput<CR>', { desc = 'close output window', silent = true })
    map('n', '<localleader>md', ':MoltenDelete<CR>', { desc = 'delete Molten cell', silent = true })
    map('n', '<localleader>mx', ':MoltenOpenInBrowser<CR>', { desc = 'open output in browser', silent = true })

    local runner = require 'quarto.runner'
    map('n', '<localleader>rc', runner.run_cell, { desc = 'run cell', silent = true })
    map('n', '<localleader>ra', runner.run_above, { desc = 'run cell and above', silent = true })
    map('n', '<localleader>rA', runner.run_all, { desc = 'run all cells', silent = true })
    map('n', '<localleader>rl', runner.run_line, { desc = 'run line', silent = true })
    map('v', '<localleader>r', runner.run_range, { desc = 'run visual range', silent = true })
    map('n', '<localleader>RA', function()
      runner.run_all(true)
    end, { desc = 'run all cells of all languages', silent = true })
  end,
  init = function()
    vim.g.molten_image_provider = 'image.nvim'
    vim.g.molten_auto_open_output = true
    vim.g.molten_auto_open_html_in_browser = true
    vim.g.molten_tick_rate = 200
    vim.g.molten_output_win_max_height = 20
    vim.g.molten_wrap_output = true
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true

    -- point Neovim’s Python host to venv
    local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
    if venv then
      local py = venv .. '/bin/python'
      if vim.fn.filereadable(py) == 1 then
        vim.g.python3_host_prog = py
      end
    end

    -- automatically import output chunks from a jupyter notebook
    -- tries to find a kernel that matches the kernel in the jupyter notebook
    -- falls back to a kernel that matches the name of the active venv (if any)
    local imb = function(e) -- init molten buffer
      vim.schedule(function()
        local kernels = vim.fn.MoltenAvailableKernels()
        local try_kernel_name = function()
          local metadata = vim.json.decode(io.open(e.file, 'r'):read 'a')['metadata']
          return metadata.kernelspec.name
        end
        local ok, kernel_name = pcall(try_kernel_name)
        if not ok or not vim.tbl_contains(kernels, kernel_name) then
          kernel_name = nil
          if venv ~= nil then
            kernel_name = string.match(venv, '/.+/(.+)')
          end
        end
        if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
          vim.cmd(('MoltenInit %s'):format(kernel_name))
        end
        vim.cmd 'MoltenImportOutput'
      end)
    end

    -- automatically import output chunks from a jupyter notebook
    vim.api.nvim_create_autocmd('BufAdd', {
      pattern = { '*.ipynb' },
      callback = imb,
    })

    -- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = { '*.ipynb' },
      callback = function(e)
        if vim.api.nvim_get_vvar 'vim_did_enter' ~= 1 then
          imb(e)
        end
      end,
    })

    -- automatically export output chunks to a jupyter notebook on write
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = { '*.ipynb' },
      callback = function()
        if require('molten.status').initialized() == 'Molten' then
          vim.cmd 'MoltenExportOutput!'
        end
      end,
    })

    -- change the configuration when editing a python file
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = '*.py',
      callback = function(e)
        if string.match(e.file, '.otter.') then
          return
        end
        if require('molten.status').initialized() == 'Molten' then -- this is kinda a hack...
          vim.fn.MoltenUpdateOption('virt_lines_off_by_1', false)
          vim.fn.MoltenUpdateOption('virt_text_output', false)
        else
          vim.g.molten_virt_lines_off_by_1 = false
          vim.g.molten_virt_text_output = false
        end
      end,
    })

    -- Undo those config changes when we go back to a markdown or quarto file
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = { '*.qmd', '*.md', '*.ipynb' },
      callback = function(e)
        if string.match(e.file, '.otter.') then
          return
        end
        if require('molten.status').initialized() == 'Molten' then
          vim.fn.MoltenUpdateOption('virt_lines_off_by_1', true)
          vim.fn.MoltenUpdateOption('virt_text_output', true)
        else
          vim.g.molten_virt_lines_off_by_1 = true
          vim.g.molten_virt_text_output = true
        end
      end,
    })

    -- Provide a command to create a blank new Python notebook
    -- note: the metadata is needed for Jupytext to understand how to parse the notebook.
    -- if you use another language than Python, you should change it in the template.
    local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

    local function new_notebook(filename)
      local path = filename .. '.ipynb'
      local file = io.open(path, 'w')
      if file then
        file:write(default_notebook)
        file:close()
        vim.cmd('edit ' .. path)
      else
        print 'Error: Could not open new notebook file for writing.'
      end
    end

    vim.api.nvim_create_user_command('NewNotebook', function(opts)
      new_notebook(opts.args)
    end, {
      nargs = 1,
      complete = 'file',
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function()
        require('quarto').activate()
      end,
    })

    vim.api.nvim_create_autocmd('DirChanged', {
      pattern = { '*' },
      callback = function(ctx)
        local new_dir = ctx.file:gsub("'", "\\'")
        if vim.fn.exists ':MoltenEvaluateArgument' ~= 2 then
          return
        end
        if require('molten.status').initialized() ~= 'Molten' then
          return
        end

        local snippets = {
          'import os',
          ("os.chdir('%s')"):format(new_dir),
        }

        for _, line in ipairs(snippets) do
          local cmd = 'MoltenEvaluateArgument ' .. line
          pcall(function()
            vim.cmd(cmd)
          end)
        end
      end,
    })
  end,
}
