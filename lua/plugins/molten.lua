local utils = require 'nixCatsUtils'
if not utils.enableForCategory('python', false) then
  return {}
end

-- auto-import outputs and start a kernel that matches notebook metadata
local function init_molten_buf(e)
  vim.schedule(function()
    local kspec = (vim.fn.json_decode(io.open(e.file, 'r'):read 'a').metadata or {}).kernelspec or {}
    local wanted = kspec.name
    local kernels = vim.fn.MoltenAvailableKernels()
    if not vim.tbl_contains(kernels, wanted) then
      wanted = nil -- fall back to active venv
      local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
      if venv then
        wanted = venv:match '.*/(.*)'
      end
    end
    if wanted and vim.tbl_contains(kernels, wanted) then
      vim.cmd(('MoltenInit %s'):format(wanted))
    end
    vim.cmd 'MoltenImportOutput'
  end)
end

vim.api.nvim_create_autocmd({ 'BufAdd', 'BufEnter' }, {
  pattern = '*.ipynb',
  callback = init_molten_buf,
})

-- export outputs back to the notebook on write
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.ipynb',
  callback = function()
    if require('molten.status').initialized() == 'Molten' then
      vim.cmd 'MoltenExportOutput!'
    end
  end,
})

-- quiet inline output for plain .py buffers, restore for md/qmd/ipynb
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.py',
  callback = function()
    if require('molten.status').initialized() == 'Molten' then
      vim.fn.MoltenUpdateOption('virt_text_output', false)
      vim.fn.MoltenUpdateOption('virt_lines_off_by_1', false)
    end
  end,
})
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.md', '*.qmd', '*.ipynb' },
  callback = function()
    if require('molten.status').initialized() == 'Molten' then
      vim.fn.MoltenUpdateOption('virt_text_output', true)
      vim.fn.MoltenUpdateOption('virt_lines_off_by_1', true)
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
      -- vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_auto_open_html_in_browser = true
      vim.g.molten_tick_rate = 200
    end,
    config = function()
      local init = function()
        local quarto_cfg = require('quarto.config').config
        quarto_cfg.codeRunner.default_method = 'molten'
        vim.cmd [[MoltenInit]]
      end
      local deinit = function()
        local quarto_cfg = require('quarto.config').config
        quarto_cfg.codeRunner.default_method = 'slime'
        vim.cmd [[MoltenDeinit]]
      end
      vim.keymap.set('n', '<localleader>mi', init, { silent = true, desc = 'Initialize molten' })
      vim.keymap.set('n', '<localleader>md', deinit, { silent = true, desc = 'Stop molten' })
      vim.keymap.set('n', '<localleader>mp', ':MoltenImagePopup<CR>', { silent = true, desc = 'molten image popup' })
      vim.keymap.set('n', '<localleader>mb', ':MoltenOpenInBrowser<CR>', { silent = true, desc = 'molten open in browser' })
      vim.keymap.set('n', '<localleader>mh', ':MoltenHideOutput<CR>', { silent = true, desc = 'hide output' })
      vim.keymap.set('n', '<localleader>ms', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = 'show/enter output' })
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
