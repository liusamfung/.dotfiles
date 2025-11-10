return {
  {
    'nvim-mini/mini.surround',
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      },
    },
  },

  {
    'nvim-mini/mini.pairs',
    event = 'VeryLazy',
    opts = {
      modes = { insert = true, command = true, terminal = true },
      -- skip autopair when next character is one of these
      -- skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- -- skip autopair when the cursor is inside these treesitter nodes
      -- skip_ts = { 'string' },
      -- -- skip autopair when next character is closing pair
      -- -- and there are more closing pairs than opening pairs
      -- skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
    --También usó funciones despues de opts!!!!!
    -- config = function(_, opts)
    --   LazyVim.mini.pairs(opts)
    -- end,
  },

  {
    'nvim-mini/mini.ai',
    -- Number of lines within which textobject is searched
    n_lines = 500,
  },

  --     require('mini.ai').setup { n_lines = 500 }
}
