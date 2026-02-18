return {
  -- Markdown-preview.nvim - Preview markdown files in browser
  {
    'markdown-preview.nvim',
    for_cat = 'general.markdown',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreview <CR>', mode = { 'n' }, noremap = true, desc = 'markdown preview' },
      { '<leader>ms', '<cmd>MarkdownPreviewStop <CR>', mode = { 'n' }, noremap = true, desc = 'markdown preview stop' },
      { '<leader>mt', '<cmd>MarkdownPreviewToggle <CR>', mode = { 'n' }, noremap = true, desc = 'markdown preview toggle' },
    },
  },

  -- Render-markdown.nvim - Render markdown in buffer
  {
    'render-markdown.nvim',
    for_cat = 'general.markdown',
    ft = { 'markdown' },
    on_require = { 'render-markdown' },
    after = function()
      require('render-markdown').setup {
        -- Whether Markdown should be rendered by default or not
        enabled = true,
        -- Maximum file size (in MB) that this plugin will attempt to render
        -- Any file larger than this will effectively be ignored
        max_file_size = 1.5,
        -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
        -- Only intended to be used for plugin development / debugging
        log_level = 'error',
      }
    end,
    keys = {
      {
        '<leader>mr',
        '<cmd>RenderMarkdown toggle<cr>',
        desc = 'markdown render toggle',
        ft = 'markdown',
      },
    },
  },

  -- Obsidian.nvim - Note management system
  {
    'obsidian.nvim',
    for_cat = 'general.markdown',
    ft = 'markdown',
    keys = {
      { '<leader>zz', '<cmd>Obsidian<cr>', desc = 'Obsidian', mode = { 'n', 'v' } },
      { '<leader>zb', '<cmd>Obsidian backlinks<cr>', desc = 'View backlinks' },
      { '<leader>ze', '<cmd>Obsidian extract_note<cr>', desc = 'Extract note', mode = 'v' },
      { '<leader>zll', '<cmd>Obsidian link<cr>', desc = 'Link to existing note', mode = 'v' },
      { '<leader>zln', '<cmd>Obsidian link_new<cr>', desc = 'Create new link', mode = 'v' },
      { '<leader>zlf', '<cmd>Obsidian links<cr>', desc = 'View links' },
      { '<leader>zn', '<cmd>Obsidian new<cr>', desc = 'New note' },
      { '<leader>zo', '<cmd>Obsidian open<cr>', desc = 'Open in obsidian' },
      { '<leader>zp', '<cmd>Obsidian paste_image<cr>', desc = 'Paste image' },
      { '<leader>zf', '<cmd>Obsidian quick_switch<cr>', desc = 'Find notes' },
      { '<leader>zr', '<cmd>Obsidian rename<cr>', desc = 'Rename note' },
      { '<leader>zg', '<cmd>Obsidian search<cr>', desc = 'Grep notes' },
      { '<leader>zt', '<cmd>Obsidian tags<cr>', desc = 'View tags' },
      { '<leader>zw', '<cmd>Obsidian workspace<cr>', desc = 'Switch workspace' },
    },
    after = function()
      require('obsidian').setup {
        workspaces = {
          {
            name = 'personal',
            path = '~/Projects/SecondBrain/personal',
          },
          {
            name = 'work',
            path = '~/Projects/SecondBrain/work',
          },
          {
            name = 'vault',
            path = '~/Projects/SecondBrain', -- Generic vault location
          },
        },
        legacy_commands = false,

        -- Completion configuration for blink.cmp
        completion = {
          nvim_cmp = false,
          blink = true,
          min_chars = 0,
        },

        -- Note ID generation
        note_id_func = function(title)
          -- Create note IDs from title
          if title ~= nil then
            return title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
          else
            -- If no title, use timestamp
            return tostring(os.time())
          end
        end,

        -- UI settings
        ui = {
          enable = true,
        },
      }
    end,
  },
}
