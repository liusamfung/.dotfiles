local M = {}

function M:setup()
  local home = os.getenv 'HOME'
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local workspace_dir = vim.fn.stdpath 'data' .. package.config:sub(1, 1) .. 'jdtls-workspace' .. package.config:sub(1, 1) .. project_name
  local os_name = vim.loop.os_uname().sysname -- 'Darwin' for macos
  local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {
      -- 💀
      'java', -- or '/path/to/java17_or_newer/bin/java'
      -- depends on if `java` is in your $PATH env variable and if it points to the right version.

      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xmx1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
      '-javaagent:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar',
      -- 💀
      '-jar',
      vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
      -- Must point to the                                                     Change this to
      -- eclipse.jdt.ls installation                                           the actual version

      -- '-configuration',
      -- home .. '/.local/share/nvim/mason/packages/jdtls/config_mac',
      -- 💀
      '-configuration',
      vim.fn.stdpath 'data'
        .. package.config:sub(1, 1)
        .. 'mason'
        .. package.config:sub(1, 1)
        .. 'packages'
        .. package.config:sub(1, 1)
        .. 'jdtls'
        .. package.config:sub(1, 1)
        .. 'config_'
        .. (os_name == 'Windows_NT' and 'win' or os_name == 'Linux' and 'linux' or 'mac'),
      -- eclipse.jdt.ls installation            Depending on your system.
      -- 💀
      -- See `data directory configuration` section in the README
      '-data',
      workspace_dir,
    },

    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir
    root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
      java = {
        autobuild = { --Si el proyecto es demasiado grande, desactivalo!!!!
          enabled = true,
        },
        saveActions = {
          -- organizeImports = true, -- google-java-format ya lo hace por mi.
          cleanup = true,
        },
        cleanup = {
          actionsOnSave = {
            'addOverride', -- Añade @Override donde falta
            -- 'addFinalModifier', -- Añade 'final' a variables locales inmutables (Hay que promover calidad de código)
            'qualifyMembers', -- Cualifica miembros con 'this.'
            'qualifyStaticMembers', -- Esta acción asegura que los miembros estáticos se referencien de la manera correcta y más clara.
            'stringConcatToTextBlock', --(Ej: "Hola\n" + "Mundo" pasa a """Hola\nMundo""").
            'invertEquals', -- Ayuda a prevenir errores de NullPointerException (Ej: variable.equals("literal") se convierte en "literal".equals(variable)).
            'lambdaExpression', -- cambia las funciones anonimas por arrowfuction
            'switchExpression', -- Elimina los breaks innecesarios y ahorra lineas de código.
          },
        },
        implementationCodeLens = 'all', --Ver  todas las implementaciones
        maven = {
          downloadSources = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        references = {
          includeDecompiledSources = true, --Código descompilado es una reconstrucción aproximada y no siempre es idéntico al código fuente original.
        },
        -- If changes to the project will require the developer to update the projects configuration advise the developer before accepting the change
        configuration = {
          updateBuildConfiguration = 'interactive',
        },
        signatureHelp = { enabled = true }, --Very helpfull (Muestra una pequeña ventana emergente mostrandote informacion de los parámetros cuando estas llamando una función.)
        inlayHints = {
          parameterNames = {
            enabled = 'all', -- literals, all, none
          },
        },
        format = { -- No necesito que el LSP formatee si codigo, ya uso un formater (google-java-formater) para archivos java.
          enabled = false,
        },
      },
    },

    -- Language server `initializationOptions`
    -- You need to extend the `bundles` with paths to jar files
    -- if you want to use additional eclipse.jdt.ls plugins.
    --
    -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
    init_options = {
      bundles = {},
    },
  }
  -- This starts a new client & server,
  -- or attaches to an existing client & server depending on the `root_dir`.
  require('jdtls').start_or_attach(config)
end

return M
