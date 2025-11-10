return {

  { -- Autocompletion
    --Blink.cmp es el que se encarga de mostrar el UI. Y recibe datos de un
    --engien(LuaSnip)
    'saghen/blink.cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    version = '1.*',
    dependencies = {
      'folke/lazydev.nvim',
      -- Snippet Engine- Es el motor del autocmopletado.
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          { -- friendly-snippets establece snippets pretederminados o preconfigurados para cada
            -- tipo de archivo popular (Muy sumilar a mason-lspconfig)
            'rafamadriz/friendly-snippets',
            -- La documentación recomienda habilitard de la siguiente forma para evitar errores
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
        opts = {},
      },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      snippets = { preset = 'luasnip' }, --El es default y el mas moderno
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'normal',
      },

      completion = {
        trigger = {
          show_on_keyword = true,
          show_on_backspace = true, --Muestra la sugerencia cuando borras palabras
          show_in_snippet = true,
        },
        keyword = { range = 'full' },

        list = {
          selection = { --Recomndado per la documentation para Supet-tab
            -- Un artificio para que cuando halla un snippet activo, no se
            -- preselecc la lista y asi puedes seguir tu flujo de "tab-tab-tab"
            -- en el snippet
            preselect = true,
            auto_insert = true,
          },
        }, -- Si no quieres que te auto seleccione la primera opción.
        --auto_insert = cuando scrolee entre las opciones, se insertará el texto ene buffer y cambiará segun la opción.

        --Auto insert final bracket or parenthesis (if env let do it)
        accept = { auto_brackets = { enabled = true } },
        menu = { -- Don't automatically show the completion menu
          draw = { treesitter = { 'lsp' } },
        }, --NOTE:Colorea las opciones de autocompletados con apoyo de treesitter
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 0 }, --Muestra una ventana emergente con informacion(Documentacion que hace la función o de donde viene la variable).
        ghost_text = { enabled = true }, -- Display a preview of the selected item on the current line
      },

      sources = {
        -- adding any nvim-cmp sources here will enable them
        -- with blink.compat
        -- compat = {},
        default = { 'lsp', 'path', 'snippets', 'lazydev', 'buffer' }, --NOTE: La tabla esta ordenada por prioridad, siendo 1ero 'lsp' y ultima 'buffer'
        --Si no quieres que te muestre como sugerencia palabras que escribiste en este buffer, elimina "buffres"

        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true }, --NOTE:Obviously you've to enable this option in your lspconfig also

      cmdline = {
        enabled = true,
        keymap = {
          preset = 'inherit', --Hereda la configuración del principal
          ['<Right>'] = false,
          ['<Left>'] = false,
        },
        completion = {
          list = { selection = { preselect = true, auto_insert = true } },
          menu = {
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ':'
            end,
          },
          ghost_text = { enabled = true }, --Only available using noice.nvim commnadline pop up
        },
      },

      -- TODO: BUSCAR COMO LLEVAR VAR BLIKNK.CMP A LA TERM DE NVIM
      -- term = {
      --   enabled = true,
      --   completion = {
      --     menu = {
      --
      --       auto_show = true,
      --     },
      --   },
      -- },
      keymap = {
        preset = 'super-tab',
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },
    },
  },
}
