return {
  {
    'mfussenegger/nvim-lint',
    -- [Requerido] Asegúrate de que 'eslint_d' esté instalado con Mason
    dependencies = { 'mason.nvim' },
    -- Si no declaras la dependencia, lazy.nvim podría cargar nvim-lint primero. Cuando nvim-lint se ejecuta, busca eslint_d en el PATH que aún no ha sido actualizado por Mason, y falla al encontrar la herramienta.
    -- Al poner dependencies = { 'mason.nvim' }, le garantizas a lazy.nvim que mason.nvim se cargará y ejecutará completamente antes de que se ejecute la función config de nvim-lint.
    -- [Opcional] Usamos 'event' para cargar nvim-lint solo cuando se edita un buffer
    events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
    -- Con la línea de arriba le estás diciendo al gestor de paquetes(lazy.nvim):
    -- "Solo carga en memoria el código del plugin nvim-lint (ejecuta su setup() o config() si existe) la primera vez que ocurra cualquiera de estos eventos."
    -- Si el evento no ocurre: El plugin permanece en modo de espera, y el tiempo de inicio de Neovim es rápido.
    -- El evento de carga NO le dice al plugin lo que debe hacer. Solo le dice al gestor de paquetes cuándo debe estar disponible.
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        -- javascriptreact = { 'eslint_d' },
        -- typescriptreact = { 'eslint_d' },
      }

      vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave', 'BufReadPost' }, {
        --el primer argumento de vim.api.nvim_create_autocmd acepta una tabla de strings para los eventos: { 'Evento1', 'Evento2', '...' }
        group = vim.api.nvim_create_augroup('CustomLinterGroup', { clear = true }),
        -- pattern = { '*.js', '*.ts', '*.jsx', '*.tsx' }, -- Opcional: solo para estos archivos  El campo pattern define a qué buffers (archivos abiertos) se aplicará la regla del autocommand cuando el evento (BufWritePost, InsertLeave, etc.) ocurra.
        callback = function()
          -- Neovim API (nvim_create_autocmd) -> Un callback es una función que se pasa como argumento a otra función (o API) con la expectativa de que será ejecutada en un momento posterior, cuando se complete alguna tarea o se dispare un evento.
          -- Lenguaje Lua -> jEs una función anónima de Lua (una función sin nombre).
          lint.try_lint() -- <- nvim-lint
        end,
        -- Es el callback el que te permite "inyectar" código del plugin en la API central de eventos de Neovim.
      })
    end,
  },
}
