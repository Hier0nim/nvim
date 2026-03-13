local M = {}

---Attach shared LSP keymaps and commands to a buffer.
---@param bufnr integer
function M.attach(bufnr)
  if vim.b[bufnr].shared_lsp_attached then
    return
  end
  vim.b[bufnr].shared_lsp_attached = true

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

  ---Print the workspace folders attached to the current buffer.
  local function list_workspace_folders()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end

  ---Format the current buffer using LSP.
  local function format_buffer()
    vim.lsp.buf.format()
  end

  ---Go to declaration only if supported by an attached client.
  local function goto_declaration()
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    for _, client in ipairs(clients) do
      if client:supports_method('textDocument/declaration') then
        vim.lsp.buf.declaration()
        return
      end
    end

    vim.notify('LSP declaration is not supported for this buffer', vim.log.levels.WARN)
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('gl', vim.lsp.codelens.run, 'Run Codelens')

  nmap('gr', Snacks.picker.lsp_references, '[G]oto [R]eferences')
  nmap('gI', Snacks.picker.lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>ds', Snacks.picker.lsp_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', Snacks.picker.lsp_workspace_symbols, '[W]orkspace [S]ymbols')

  nmap('K', vim.lsp.buf.hover, 'Hover documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature documentation')
  nmap('gD', goto_declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove folder')
  nmap('<leader>wl', list_workspace_folders, '[W]orkspace [L]ist folders')
  nmap('<leader>cl', vim.lsp.codelens.run, 'Run [C]ode[L]ens')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', format_buffer, {
    desc = 'Format current buffer with LSP',
  })
end

---Backwards-compatible on_attach entry point.
---@param _ any
---@param bufnr integer
function M.on_attach(_, bufnr)
  M.attach(bufnr)
end

-- Apply shared LSP behavior whenever any LSP client attaches.
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Attach shared LSP keymaps',
  callback = function(args)
    M.attach(args.buf)
  end,
})

return M
