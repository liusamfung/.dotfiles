return {
  {
    'tpope/vim-dadbod',
    -- cmd = 'DB',
  },

  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    keys = {
      { '<leader>D', '<cmd>DBUIToggle<CR>', desc = 'Toggle DBUI' },
    },
    -- Tienes que agregar dadbod como dependecia, ya que si dadbod aun no esta
    -- iniciado, (Porque en ningun momento le dijimos que se inicie apenas estramos a nvim)
    -- Te dará errores al concetar una base de datos o otras mas características.
  },

  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = function()
      require('lazy').load { plugins = { 'markdown-preview.nvim' } }
      vim.fn['mkdp#util#install']()
    end,
    keys = {
      {
        '<leader>cp',
        ft = 'markdown',
        '<cmd>MarkdownPreviewToggle<cr>',
        desc = 'Markdown Preview',
      },
    },
    init = function()
      -- Usa "google-chrome" para Linux, o el nombre de tu ejecutable.
      -- Para Windows/macOS, usa el comando que abre Chrome (ver notas abajo).
      vim.g.mkdp_browser = '/Applications/Google Chrome.app'

      -- Dentro de tu archivo de configuración (ej. init.lua o la tabla de lazy.nvim)
      vim.g.mkdp_page_html_head = [[
<script src="https://cdn.jsdelivr.net/npm/mermaid@10.2.3/dist/mermaid.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', (event) => {
        mermaid.initialize({ startOnLoad: true });
    });
</script>
]]
    end,
    config = function()
      vim.cmd [[do FileType]]
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      code = {
        sign = false,
        width = 'block',
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
      checkbox = {
        enabled = false,
      },
    },
    ft = { 'markdown', 'norg', 'rmd', 'org', 'codecompanion' },
    config = function(_, opts)
      require('render-markdown').setup(opts)
      Snacks.toggle({
        name = 'Render Markdown',
        get = require('render-markdown').get,
        set = require('render-markdown').set,
      }):map '<leader>um'
    end,
  },
  {
    'lervag/vimtex',
    lazy = false, -- lazy-loading will disable inverse search
    config = function()
      vim.g.vimtex_mappings_disable = { ['n'] = { 'K' } } -- disable `K` as it conflicts with LSP hover
      vim.g.vimtex_quickfix_method = vim.fn.executable 'pplatex' == 1 and 'pplatex' or 'latexlog'
    end,
    keys = {
      { '<localLeader>l', '', desc = '+vimtex', ft = 'tex' },
    },
  },
}
