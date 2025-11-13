return {
  {
    'stevearc/conform.nvim',
    dependencies = { 'mason.nvim' },
    lazy = true,
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cF',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      -- notify_on_error = false, --kickstart
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        -- local disable_filetypes = { c = true, cpp = true }
        local disable_filetypes = {}
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            async = false, -- not recommended to change Si cambias esto a async = true, el formateo se iniciaría en segundo plano, pero Neovim podría guardar el archivo antes de que el formateo termine y aplique los cambios.
            quiet = false, -- not recommended to change mostrará un mensaje de error si el formateador falla o se produce un timeout. Si fuera true, el error se suprimiría.
            lsp_format = 'fallback', -- not recommended to change -> Usar 'fallback' asegura que, en el peor de los casos, si no tienes Prettier configurado para un archivo, tu servidor de lenguaje (LSP) intente formatearlo.
          }
        end
      end,
      formatters_by_ft = {
        c = { 'clang-format' },
        cpp = { 'clang-format' },

        java = { 'google-java-format' },

        lua = { 'stylua' },
        sh = { 'shfmt' }, -- archivos bassh y zsh

        -- Web development
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' }, -- Para archivos .jsx (React)
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' }, -- Para archivos .tsx (React con TypeScript
        html = { 'prettierd' },
        css = { 'prettierd' },
        scss = { 'prettierd' },
        less = { 'prettierd' },
        json = { 'prettierd' },
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },

        mysql = { 'sqlfluff' },

        -- -- ⚙️ Backend (Ejemplos, pueden variar según tu stack)
        --     python = { 'black' },  -- Si usas Python
        --     go = { 'gofmt' },      -- Si usas Go
        --     java = { 'astyle' },   -- Si usas Java (requiere el formateador astyle)

        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      }, -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        sqlfluff = {
          args = { 'format', '--dialect=ansi', '-' },
        },

        -- injected = { options = { ignore_errors = true } },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
    },
  },
}
