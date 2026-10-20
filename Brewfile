# Core of the terminal flow. install.sh runs `brew bundle` on this file; Brewfile.extras is opt-in (--extras).
# Check without installing:  brew bundle check --file Brewfile

# Shell: plugins sourced by .zshrc, prompt, aliases (eza, trash)
brew "zsh-autosuggestions"
brew "zsh-vi-mode"
brew "starship"
brew "fzf"
brew "eza"
brew "zoxide"
brew "bat"
brew "trash-cli"

# Terminal tools used by kitty sessions, lazygit and yazi
brew "yazi"
brew "lazygit"
brew "gh"
brew "git"
brew "btop"
brew "ov"
brew "fswatch"
brew "jq"
brew "ripgrep"
brew "fd"

# yazi previews and plugins (images, pdf, svg, video, archives)
brew "ffmpeg"
brew "sevenzip"
brew "poppler"
brew "resvg"
brew "imagemagick"  # not a leaf on the author's Mac (a dependency there)
brew "ghostscript"  # not a leaf on the author's Mac (a dependency there)
brew "chafa"
brew "exiftool"  # yazi's "Show EXIF" entry in the Shift+O menu
brew "ouch"

# Neovim: editor, parsers, Mason (needs python3 for its pip packages), LuaSnip/telescope builds, sf.nvim
brew "neovim"
brew "tree-sitter-cli"
brew "luarocks"
brew "watchman"
brew "python@3.12"
brew "universal-ctags"

# Runtimes: node comes from mise (mise/config.toml); the JDK is for apex_ls / jdtls
brew "mise"  # not a leaf on the author's Mac (a dependency there)
brew "openjdk@21"

# The terminal itself and its font (kitty/kitty.conf uses JetBrainsMono Nerd Font; the symbols font fills the icon gaps)
cask "kitty"
cask "font-jetbrains-mono-nerd-font"
cask "font-symbols-only-nerd-font"
