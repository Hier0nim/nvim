return {
  {
    'easy-dotnet.nvim',
    ft = { 'cs', 'csproj', 'fsproj', 'sln', 'slnx' },
    cmd = { 'Dotnet' },
    after = function()
      local dotnet = require 'easy-dotnet'

      dotnet.setup {
        picker = 'snacks',
      }

      -- Add easy-dotnet job status to lualine after the UI has finished loading.
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DeferredUIEnter',
        once = true,
        callback = function()
          local ok_lualine, lualine = pcall(require, 'lualine')
          if not ok_lualine then
            return
          end

          local ok_jobs, jobs = pcall(require, 'easy-dotnet.ui-modules.jobs')
          if not ok_jobs then
            return
          end

          local config = lualine.get_config()
          config.sections = config.sections or {}
          config.sections.lualine_x = config.sections.lualine_x or {}

          table.insert(config.sections.lualine_x, 1, jobs.lualine)
          lualine.setup(config)
        end,
      })

      -- Add dotnet template creation to mini.files buffers.
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id

          vim.keymap.set('n', '<leader>a', function()
            local entry = require('mini.files').get_fs_entry()
            if entry == nil then
              vim.notify('No fs entry in mini.files', vim.log.levels.WARN)
              return
            end

            local target_dir = entry.path
            if entry.fs_type == 'file' then
              target_dir = vim.fn.fnamemodify(entry.path, ':h')
            end

            dotnet.create_new_item(target_dir)
          end, {
            buffer = buf_id,
            desc = 'Create file from dotnet template',
          })
        end,
      })
    end,
  },
}
