return {
  -- #001013 color scheme default
  --
  -- #767676 color back
  {
    -- Shortend Github urlr
    'craftzdog/solarized-osaka.nvim',
    lazy = false,
    priority = 1000, --Load first first first
    config = function()
      require('solarized-osaka').setup {
        transparent = true,
        styles = {
          comments = { italic = true }, -- Enable italics in comments
          functions = { italic = true, bold = true },
          keywords = { bold = true }, -- Anotaciones, palabras reservadas, etc
        },
      }
      --     -- Load the colorscheme here.
      --     -- Like many other themes, this one has different styles, and you could load
      --     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      --     vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.colorscheme 'solarized-osaka'
    end,
  },

  -- {
  --   'cpea2506/one_monokai.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('one_monokai').setup {
  --       transparent = true,
  --       colors = {},
  --       highlights = function(colors)
  --         return {}
  --       end,
  --       italics = true,
  --     }
  --     vim.cmd.colorscheme 'one_monokai'
  --   end,
  -- },
  --
  -- {
  --   'EdenEast/nightfox.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('nightfox').setup {
  --       options = {
  --         styles = {
  --           comments = 'italic',
  --           keywords = 'bold',
  --           -- types = 'italic,bold',
  --         },
  --       },
  --     }
  --     vim.cmd 'colorscheme duskfox'
  --   end,
  -- },

  -- {
  --   'Ronxvier/ymir.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd 'colorscheme ymir'
  --   end,
  -- },
}
