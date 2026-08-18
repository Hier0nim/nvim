local M = {}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspKeymaps', { clear = true }),
  desc = 'LSP buffer-local keymaps and commands',
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Disable hover for ruff in favor of basedpyright
    if client and client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end

    ---Set a normal-mode LSP keymap scoped to the buffer.
    ---@param keys string
    ---@param func function
    ---@param desc string|nil
    local function nmap(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    local Snacks = require 'snacks'

    nmap('gd', Snacks.picker.lsp_definitions, '[G]oto [D]efinition')
    nmap('grr', Snacks.picker.lsp_references, '[G]oto [R]eferences')
    nmap('gri', Snacks.picker.lsp_implementations, '[G]oto [I]mplementation')

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
      require('conform').format { lsp_format = 'fallback', async = false, timeout_ms = 3000 }
    end, { desc = 'Format current buffer' })
  end,
})

return M
