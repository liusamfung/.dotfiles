return {
  -- LSP keymaps
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- -- change a keymap
      -- keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
      -- disable a keymap
      keys[#keys + 1] = { "K", false }
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        --Java development
        "java-debug-adapter",
        "java-test",
        "jdtls",
        --Salesforce (CRM)
        "apex-language-server",
        --Web development
        "typescript-language-server",
        "css-lsp",
        "json-lsp",
        "prettier", --formating
        "html-lsp",
        --Single Files LSP
        "clangd",
        "lua-language-server",
        "stylua", --formating luafiles
        "texlab", -- LaTex
        "bash-language-server",
        "shfmt", --Formating bash

        "sqlls",

        -- "marksman",
      },
    },
  },
}
