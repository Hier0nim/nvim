local utils = require 'nixCatsUtils'
if not utils.enableForCategory('python', false) then
  return {}
end

local venv_python = os.getenv 'VIRTUAL_ENV' and (os.getenv 'VIRTUAL_ENV' .. '/bin/python')
if venv_python and vim.fn.filereadable(venv_python) == 1 then
  vim.g.python3_host_prog = venv_python
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
      local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
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

return {
  {
    'quarto-dev/quarto-nvim',
    opts = {
      lspFeatures = {
        enabled = true,
        chunks = 'curly',
      },
      codeRunner = {
        enabled = true,
        default_method = 'slime',
      },
    },
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua
      'jmbuhr/otter.nvim',
    },
  },

  { -- directly open ipynb files as quarto docuements
    -- and convert back behind the scenes
    'GCBallesteros/jupytext.nvim',
    config = true,
    opts = {
      style = 'markdown',
      output_extension = 'md',
      force_ft = 'markdown',
      lazy = false,
    },
  },

  { -- paste an image from the clipboard or drag-and-drop
    'HakonHarnes/img-clip.nvim',
    event = 'BufEnter',
    ft = { 'markdown', 'quarto', 'latex' },
    opts = {
      default = {
        dir_path = 'img',
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
        quarto = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    config = function(_, opts)
      require('img-clip').setup(opts)
      vim.keymap.set('n', '<leader>ii', ':PasteImage<cr>', { desc = 'insert [i]mage from clipboard' })
    end,
  },

  { -- preview equations
    'jbyuki/nabla.nvim',
    keys = {
      { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'toggle [m]ath equations' },
    },
  },

  {
    'benlubas/molten-nvim',
    enabled = true,
    build = ':UpdateRemotePlugins',
    init = function()
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_auto_open_output = true
      vim.g.molten_auto_open_html_in_browser = true
      vim.g.molten_tick_rate = 200
    end,
    config = function()
      vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>', { silent = true, desc = 'Initialize the plugin' })
      vim.keymap.set('n', '<localleader>e', ':MoltenEvaluateOperator<CR>', { silent = true, desc = 'run operator selection' })
      vim.keymap.set('n', '<localleader>rl', ':MoltenEvaluateLine<CR>', { silent = true, desc = 'evaluate line' })
      vim.keymap.set('n', '<localleader>rr', ':MoltenReevaluateCell<CR>', { silent = true, desc = 're-evaluate cell' })
      vim.keymap.set('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = 'evaluate visual selection' })
      vim.keymap.set('n', '<localleader>rd', ':MoltenDelete<CR>', { silent = true, desc = 'molten delete cell' })
      vim.keymap.set('n', '<localleader>oh', ':MoltenHideOutput<CR>', { silent = true, desc = 'hide output' })
      vim.keymap.set('n', '<localleader>os', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = 'show/enter output' })
    end,
  },
  {
    -- see the image.nvim readme for more information about configuring this plugin
    '3rd/image.nvim',
    opts = {
      backend = 'kitty', -- whatever backend you would like to use
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
    },
  },
}
