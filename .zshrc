# Homebrew: .zprofile does this for login shells; this covers a shell that did not inherit it.
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $brew_bin ]] && eval "$($brew_bin shellenv)" && break
  done
fi

# Path to your Oh My Zsh installation (install.sh clones it).
export ZSH="$HOME/.oh-my-zsh"
DISABLE_MAGIC_FUNCTIONS="true"
plugins=( git z )
[[ -r $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

#plugins desde hombebrew
[[ -r $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r $HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]] && source $HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh


alias ll='eza -lg --group-directories-first --icons' ##Lista sin mostrar carpetas ocultas
alias la='eza -lag --group-directories-first --icons'

alias lt='eza -lTg --level=2 --group-directories-first --icons'
alias lt2='eza -lTg --level=3 --group-directories-first --icons'
alias lt3='eza -lTg  --group-directories-first --icons'

alias lta='eza -lTag --level=2 --group-directories-first --icons'
alias lta2='eza -lTag --level=3 --group-directories-first --icons'
alias lta3='eza -lTag --group-directories-first --icons'
alias nt='nvim -c "terminal"'
alias i='nvim'
alias e='exit'


alias kanata-check="~/Dev/Tools/kanata/target/release/kanata -c ~/dotfiles/kanata/config.kbd --check"
# config/kanata: variable 'lrld' reloads everything inside your layers — defsrc, deflayer, defalias, defchords, etc. It does not reload anything in the defcfg block related to which physical device kanata is attached to (things like macos-dev-names-include/exclude)
alias kanata-restart="~/Dev/Tools/kanata/target/release/kanata -c ~/dotfiles/kanata/config.kbd --check && sudo launchctl kickstart -k system/com.liusam.kanata"  

alias safe-shutdown="$HOME/dotfiles/scripts/safe-shutdown.sh"
alias safe-reboot="$HOME/dotfiles/scripts/safe-shutdown.sh reboot"
alias close-apps="$HOME/dotfiles/scripts/close-apps.sh"
alias startup-apps="$HOME/dotfiles/scripts/startup-apps.sh"
# The argument `bootout` of launchctl only unloads it for the current boot session. If you restart the laptop, RunAtLoad=true in the plist means kanata would start right back up on its own. If, you want to keep it disable until you manually come back use `disable`
alias kanata-pause="sudo launchctl disable system/com.liusam.kanata && sudo launchctl bootout system/com.liusam.kanata"
alias kanata-resume="sudo launchctl enable system/com.liusam.kanata && sudo launchctl bootstrap system /Library/LaunchDaemons/com.liusam.kanata.plist"

#  Modo interactivo (preguntará "rm ...?" antes de borrar)
#  Cuando abres en un mismo proyecto neovim(Usando apexls de mason.nvim) y 
#  vscode (Que usa el apexls descargado de las extensiones, los 2 quieres usar el mismo
#  .db. Y entre ellos corrompen el archivo. Es necesario elimnarlo para que se
#  cree uno nuevo automáticamente).
alias fixapex='find .sfdx/tools -name "apex.db" -exec rm -i {} \;'
# [S]alesforce [C]ode [A]anlyzer 
alias sca='sf code-analyzer run | less -S'


(( $+widgets[autosuggest-accept] )) && bindkey '\C-@' autosuggest-accept

(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[starship] )) && eval "$(starship init zsh)"


export LG_CONFIG_FILE="$HOME/dotfiles/lazygit/config.yml"


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

function java17() {
  export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
  echo "✅ PATH de Java cambiado a JDK 17"
  java -version
}

function java25() {
  export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
  echo "✅ PATH de Java cambiado a JDK 25"
  java -version
}


function java21() {
  # La primera exportación ya está en el .zshrc
  export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
  export PATH="$HOMEBREW_PREFIX/opt/openjdk@21/bin:$PATH"
  echo "✅ PATH de Java restaurado a JDK 21"
  java -version
}

export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/lib/ruby/gems/3.4.0/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/openjdk@21/bin:$PATH"

export PATH="$HOMEBREW_PREFIX/opt/trash-cli/bin:$PATH"


# Lazy load para el autocompletado de Angular
ng() {
    # Elimina esta función para que no se repita
    unset -f ng
    # Carga el autocompletado original
    source <(command ng completion script)
    # Ejecuta el comando ng con los argumentos originales
    command ng "$@"
}

SF_AC_ZSH_SETUP_PATH=$HOME/Library/Caches/sf/autocomplete/zsh_setup && test -f $SF_AC_ZSH_SETUP_PATH && source $SF_AC_ZSH_SETUP_PATH; # sf autocomplete setup

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
# mise (node, sf...). ~/.local/bin is where the curl installer puts it; brew's goes in the Homebrew PATH.
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"
(( $+commands[mise] )) && eval "$(mise activate zsh)"
