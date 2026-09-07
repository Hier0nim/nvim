return {
  {
    'nvim-lint',
    auto_enable = true,
    ft = { 'sh', 'bash', 'zsh', 'nu' },
    ---Configure nvim-lint for zsh and buffer-local shell keymaps.
    after = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        sh = { 'shellcheck' },
        bash = { 'shellcheck' },
        zsh = { 'zsh' },
      }

      vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('NvimLint', { clear = true }),
        desc = 'Run linter on save',
        callback = function()
          if lint.linters_by_ft[vim.bo.filetype] then lint.try_lint() end
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('ShellKeymaps', { clear = true }),
        pattern = { 'sh', 'bash', 'zsh', 'nu' },
        desc = 'Buffer-local shell keymaps',
        callback = function(args)
          local opts = { buffer = args.buf }

          vim.keymap.set('n', '<leader>rr', function()
            local shell = ({ sh = 'sh', bash = 'bash', zsh = 'zsh', nu = 'nu' })[vim.bo.filetype]
            Snacks.terminal({ shell, vim.api.nvim_buf_get_name(0) })
          end, vim.tbl_extend('force', opts, { desc = 'Run current file' }))
        end,
      })
    end,
  },
}
