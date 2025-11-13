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
}
