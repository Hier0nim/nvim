return {
  {
    'nvim-lint',
    auto_enable = true,
    ft = { 'sh', 'bash', 'zsh', 'nu' },
    ---Configure nvim-lint for zsh and buffer-local shell keymaps.
    after = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        zsh = { 'zsh' },
      }

      vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('NvimLint', { clear = true }),
        desc = 'Run linter on save',
        callback = function()
          lint.try_lint()
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('ShellKeymaps', { clear = true }),
        pattern = { 'sh', 'bash', 'zsh', 'nu' },
        desc = 'Buffer-local shell keymaps',
        callback = function(args)
          local opts = { buffer = args.buf }

          vim.keymap.set('n', '<leader>rr', function()
            local file = vim.fn.shellescape(vim.fn.expand '%:p')
            local first_line = vim.fn.getline(1)
            if first_line:match '^#!' then
              vim.cmd('!' .. file)
            else
              vim.cmd('!$SHELL ' .. file)
            end
          end, vim.tbl_extend('force', opts, { desc = 'Run current file' }))
        end,
      })
    end,
  },
}
