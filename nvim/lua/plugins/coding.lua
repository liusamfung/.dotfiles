return {
  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'gbprod/yanky.nvim',
    desc = 'Better Yank/Paste',
    opts = {
      system_clipboard = {
        sync_with_ring = not vim.env.SSH_CONNECTION,
      },
      highlight = { timer = 150 },
    },
    keys = {
        -- stylua: ignore
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Cursor' },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Cursor' },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Selection' },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Selection' },
      { '[y', '<Plug>(YankyCycleForward)', desc = 'Cycle Forward Through Yank History' },
      { ']y', '<Plug>(YankyCycleBackward)', desc = 'Cycle Backward Through Yank History' },
      { ']p', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put Indented After Cursor (Linewise)' },
      { '[p', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put Indented Before Cursor (Linewise)' },
      { ']P', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put Indented After Cursor (Linewise)' },
      { '[P', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put Indented Before Cursor (Linewise)' },
      { '>p', '<Plug>(YankyPutIndentAfterShiftRight)', desc = 'Put and Indent Right' },
      { '<p', '<Plug>(YankyPutIndentAfterShiftLeft)', desc = 'Put and Indent Left' },
      { '>P', '<Plug>(YankyPutIndentBeforeShiftRight)', desc = 'Put Before and Indent Right' },
      { '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)', desc = 'Put Before and Indent Left' },
      { '=p', '<Plug>(YankyPutAfterFilter)', desc = 'Put After Applying a Filter' },
      { '=P', '<Plug>(YankyPutBeforeFilter)', desc = 'Put Before Applying a Filter' },
    },
  },

  {
    'knubie/vim-kitty-navigator',
    build = 'cp ./*.py ~/.config/kitty/',
    -- Yo no uso el teclado QWERTY, uso dvrk. Por ello me es mas comodo rempearlo
    -- de esta forma para que todo los motions esten en una sola mano.bb
    -- Si tú usas QWERTY, qudate con la configuración por defecto.
    init = function()
      -- Deshabilita los keymaps por defecto del plugin (Vimscript: let g:kitty_navigator_no_mappings = 1)
      vim.g.kitty_navigator_no_mappings = 1
    end,
    -- Función `config`: Se ejecuta después de que el plugin se ha cargado.
    -- Aquí definimos nuestros keymaps personalizados de forma directa.
    config = function()
      local map = vim.keymap.set
      local opts = { silent = true, remap = false }
      map('n', '<C-q>', ':KittyNavigateLeft<CR>', { desc = 'Kitty: Mover Izquierda (Re-mapeado)' })
      map('n', '<C-j>', ':KittyNavigateDown<CR>', { desc = 'Kitty: Mover Abajo' })
      map('n', '<C-k>', ':KittyNavigateUp<CR>', { desc = 'Kitty: Mover Arriba' })
      map('n', '<C-x>', ':KittyNavigateRight<CR>', { desc = 'Kitty: Mover Derecha (Re-mapeado)' })
      print 'vim-kitty-navigator: Mapeos personalizados cargados (C-q, C-j, C-k, C-x).'
    end,
  },
}
