# Login shells (kitty runs `zsh --login`). Linked to ~/.zprofile by install.sh.

# python.org installer (only when present). Before Homebrew's shellenv so that Homebrew stays first in PATH.
if [[ -d /Library/Frameworks/Python.framework/Versions/3.12/bin ]]; then
  export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"
fi

# Homebrew: Apple Silicon (/opt/homebrew) or Intel (/usr/local); sets PATH, HOMEBREW_PREFIX, MANPATH...
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [[ -x $brew_bin ]]; then
    eval "$($brew_bin shellenv)"
    break
  fi
done

# User-level tools: mise, pipx apps, yt-dlp, codex
export PATH="$HOME/.local/bin:$PATH"
