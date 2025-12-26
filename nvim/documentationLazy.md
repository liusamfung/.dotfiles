# Events
- **BufReadPost:** Se dispara justo después de que Neovim termina de leer un archivo en un buffer. Es ideal para plugins que analizan el contenido (como Treesitter o resaltado de color).

- **BufNewFile:** Se activa cuando creas un archivo que aún no existe en el disco. Se usa junto a BufReadPost para cubrir ambos casos al abrir código.

- **VeryLazy:** Este es un evento propio de lazy.nvim. Carga el plugin un tiempo breve después de que Neovim ha iniciado completamente. Es perfecto para plugins que no necesitas en el primer milisegundo (como un gestor de archivos, Git, o un Dashboard).

- **BufReadPre:** Se dispara antes de cargar el contenido del archivo. Se usa para plugins que deben estar listos antes de que el texto aparezca (como nvim-lspconfig).

- **InsertEnter:** Carga el plugin en el momento exacto en que entras en Modo Inserto. Es el estándar para plugins de autocompletado (como nvim-cmp).

- **LspAttach:** Carga un plugin solo cuando un servidor LSP se ha conectado con éxito al buffer actual.

- **CmdlineEnter:** Se activa cuando presionas : para escribir un comando. Útil para plugins que mejoran la línea de comandos.

# go
- **cmd**Carga el plugin solo cuando ejecutas un comando específico.	cmd = "Mason"
- **keys**Carga el plugin cuando presionas una combinación de teclas.	keys = { "<leader>ff", "<leader>fg" }
- **ft**Carga el plugin solo para ciertos tipos de archivo (filetypes).	ft = { "lua", "python" }
- **dependencies**El plugin se carga si y solo si otro plugin lo requiere.	dependencies = { "nvim-lua/plenary.nvim" }
