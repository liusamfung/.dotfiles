#!/bin/bash
# Sets up a Mac with the author's terminal flow: Homebrew packages, config links, zsh, mise (node + sf),
# git and a ready-to-use Neovim. Idempotent: safe to run again on a configured Mac.
#
#   git clone https://github.com/liusamfung/.dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
#
#   ./install.sh               install everything, then check it
#   ./install.sh --check       only verify (changes nothing)
#   ./install.sh --dry-run     print what install would do (changes nothing)
#   ./install.sh --extras      also install Brewfile.extras (heavy, optional formulas)
#   ./install.sh --skip-brew   skip Xcode CLT / Homebrew / brew bundle (testing, or brew already handled)
#   ./install.sh --no-nvim     skip the Neovim plugin / Mason / parser download
#
# Testing without touching your real files: HOME=/some/empty/dir ./install.sh --skip-brew
# (bash 3.2 compatible: it is what macOS ships)
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=install
DRY=0
EXTRAS=0
SKIP_BREW=0
NVIM=1
BACKUP_DIR=""
FAILS=0
WARNS=0

for arg in "$@"; do
	case "$arg" in
	--check) MODE=check ;;
	--dry-run) DRY=1 ;;
	--extras) EXTRAS=1 ;;
	--skip-brew) SKIP_BREW=1 ;;
	--no-nvim) NVIM=0 ;;
	-h | --help)
		sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*)
		echo "unknown option: $arg (try --help)" >&2
		exit 2
		;;
	esac
done

# Files linked into $HOME: "<path in this repo>|<destination>"
LINKS=(
	".zshrc|$HOME/.zshrc"
	".zprofile|$HOME/.zprofile"
	".zshenv|$HOME/.zshenv"
	"nvim|$HOME/.config/nvim"
	"kitty|$HOME/.config/kitty"
	"yazi|$HOME/.config/yazi"
	"starship/starship.toml|$HOME/.config/starship.toml"
	"mise/config.toml|$HOME/.config/mise/config.toml"
	"git/config|$HOME/.config/git/config"
	"git/ignore|$HOME/.config/git/ignore"
)

# ------------------------------------------------------------------------------------------------ helpers
say() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
pass() { printf '  \033[32mOK  \033[0m %s\n' "$*"; }
warn() { printf '  \033[33mWARN\033[0m %s\n' "$*"; WARNS=$((WARNS + 1)); }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$*"; FAILS=$((FAILS + 1)); }
todo() { printf '  \033[36m..  \033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# Runs a command, or only prints it with --dry-run.
run() {
	if [ "$DRY" -eq 1 ]; then
		todo "[dry-run] $*"
		return 0
	fi
	"$@"
}

# What the author's shell has in PATH, so that this script finds the tools it just installed.
refresh_path() {
	local b
	for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
		if [ -x "$b" ]; then
			eval "$("$b" shellenv)"
			break
		fi
	done
	export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
	if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "$HOMEBREW_PREFIX/opt/openjdk@21/bin" ]; then
		export PATH="$HOMEBREW_PREFIX/opt/openjdk@21/bin:$PATH"
	fi
}

# ------------------------------------------------------------------------------------------------ steps
step_preflight() {
	say "Preflight"
	if [ "$(uname -s)" != "Darwin" ]; then
		fail "this script is for macOS"
		exit 1
	fi
	if [ "$(id -u)" -eq 0 ]; then
		fail "do not run it as root"
		exit 1
	fi
	pass "macOS $(sw_vers -productVersion 2>/dev/null) on $(uname -m)"
	if [ "$DOTFILES" = "$HOME/dotfiles" ]; then
		pass "repo at ~/dotfiles"
	else
		warn "repo is at $DOTFILES, not ~/dotfiles: kitty sessions and lazygit assume ~/dotfiles"
	fi
}

step_xcode() {
	say "Xcode Command Line Tools (git, C compiler for tree-sitter parsers)"
	if xcode-select -p >/dev/null 2>&1; then
		pass "installed"
	elif [ "$MODE" = "check" ]; then
		fail "missing: xcode-select --install"
	elif [ "$DRY" -eq 1 ]; then
		todo "[dry-run] xcode-select --install"
	else
		xcode-select --install
		echo "Finish the installer dialog that just opened, then run this script again."
		exit 1
	fi
}

step_homebrew() {
	say "Homebrew"
	refresh_path
	if have brew; then
		pass "$(brew --version | head -1)"
		return
	fi
	if [ "$MODE" = "check" ]; then
		fail "brew missing"
		return
	fi
	if [ "$DRY" -eq 1 ]; then
		todo "[dry-run] install Homebrew (asks for your password once)"
		return
	fi
	echo "Homebrew asks for your administrator password once."
	sudo -v || exit 1
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
	refresh_path
	have brew && pass "$(brew --version | head -1)" || fail "brew still missing after the install"
}

# Names of a Brewfile: "brew" lines, or "cask" lines.
brewfile_names() { # brewfile_names <file> <brew|cask>
	sed -nE "s/^$2 \"([^\"]+)\".*/\1/p" "$1"
}

step_packages() {
	say "Brew packages"
	have brew || { [ "$DRY" -eq 1 ] && todo "[dry-run] brew bundle (brew not installed yet)"; return; }
	local files=("$DOTFILES/Brewfile")
	[ "$EXTRAS" -eq 1 ] && files+=("$DOTFILES/Brewfile.extras")
	local f missing formulae casks name
	formulae="$(brew list --formula 2>/dev/null)"
	casks="$(brew list --cask 2>/dev/null)"
	for f in "${files[@]}"; do
		missing=0
		for name in $(brewfile_names "$f" brew); do
			echo "$formulae" | grep -qx "${name##*/}" || { missing=$((missing + 1)); [ "$MODE" = "check" ] && warn "not installed: $name"; }
		done
		for name in $(brewfile_names "$f" cask); do
			echo "$casks" | grep -qx "$name" || { missing=$((missing + 1)); [ "$MODE" = "check" ] && warn "not installed (cask): $name"; }
		done
		if [ "$missing" -eq 0 ]; then
			pass "$(basename "$f"): everything is installed"
		elif [ "$MODE" = "install" ]; then
			todo "$(basename "$f"): $missing missing, installing"
			run brew bundle --file "$f" || warn "brew bundle reported problems for $(basename "$f")"
		fi
	done
	[ "$EXTRAS" -eq 0 ] && todo "Brewfile.extras is optional (--extras)"
	refresh_path
}

# Moves whatever is at $1 into the backup folder (created on first use).
backup() {
	local target="$1"
	if [ -z "$BACKUP_DIR" ]; then
		BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
	fi
	mkdir -p "$BACKUP_DIR"
	mv "$target" "$BACKUP_DIR/$(basename "$target")"
	warn "existing $target moved to $BACKUP_DIR/"
}

step_links() {
	say "Links into \$HOME"
	local entry src dest
	for entry in "${LINKS[@]}"; do
		src="$DOTFILES/${entry%%|*}"
		dest="${entry#*|}"
		if [ ! -e "$src" ]; then
			fail "missing in the repo: ${entry%%|*}"
			continue
		fi
		if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
			pass "${dest/#$HOME/~}"
			continue
		fi
		if [ "$MODE" = "check" ]; then
			warn "${dest/#$HOME/~} is not linked to the repo"
			continue
		fi
		if [ "$DRY" -eq 1 ]; then
			todo "[dry-run] link ${dest/#$HOME/~} -> ${src/#$HOME/~}$([ -e "$dest" ] || [ -L "$dest" ] && echo " (existing file would be backed up)")"
			continue
		fi
		mkdir -p "$(dirname "$dest")"
		if [ -e "$dest" ] || [ -L "$dest" ]; then
			backup "$dest"
		fi
		ln -s "$src" "$dest" && pass "linked ${dest/#$HOME/~}" || fail "could not link $dest"
	done
	# Links left over from configs that were removed from the repo
	local l
	for l in "$HOME"/.config/*; do
		if [ -L "$l" ] && [ ! -e "$l" ] && readlink "$l" | grep -q "dotfiles"; then
			warn "dangling link ${l/#$HOME/~} (points into dotfiles but the target is gone): rm it"
		fi
	done
}

step_ohmyzsh() {
	say "oh-my-zsh"
	if [ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
		pass "installed"
	elif [ "$MODE" = "check" ]; then
		fail "missing (~/.oh-my-zsh)"
	elif [ "$DRY" -eq 1 ]; then
		todo "[dry-run] git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh"
	else
		git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" && pass "cloned" || fail "could not clone oh-my-zsh"
	fi
}

step_mise() {
	say "mise: node, and the Salesforce CLI installed on it (mise/config.toml)"
	if ! have mise; then
		[ "$MODE" = "check" ] && fail "mise missing (it is in the Brewfile)" || todo "mise not available yet"
		return
	fi
	if [ "$MODE" = "install" ]; then
		run mise install --yes || warn "mise install reported problems"
		refresh_path
	fi
	if [ "$DRY" -eq 1 ]; then
		todo "[dry-run] npm install -g @salesforce/cli (on mise's node)"
		return
	fi
	local node_v sf_v
	node_v="$(mise exec -- node -v 2>/dev/null)"
	if [ -z "$node_v" ]; then
		fail "node not available through mise"
		return
	fi
	pass "node $node_v"
	sf_v="$(mise exec -- sf --version 2>/dev/null | head -1)"
	if [ -z "$sf_v" ] && [ "$MODE" = "install" ]; then
		# npm -g, not mise's npm: backend (see the comment in mise/config.toml); reshim exposes the new binary
		mise exec -- npm install -g @salesforce/cli >/dev/null 2>&1 || warn "npm install -g @salesforce/cli failed"
		mise reshim >/dev/null 2>&1
		sf_v="$(mise exec -- sf --version 2>/dev/null | head -1)"
	fi
	if [ -n "$sf_v" ]; then
		pass "$sf_v"
		# The .zshrc sources this file when it exists (tab completion for sf)
		[ "$MODE" = "install" ] && { mise exec -- sf autocomplete zsh --refresh-cache >/dev/null 2>&1 || warn "sf autocomplete setup failed (non-critical)"; }
	else
		fail "sf not available through mise's node"
	fi
}

step_git() {
	say "git identity"
	if [ -n "$(git config --global --get user.email 2>/dev/null)" ] && [ -n "$(git config --global --get user.name 2>/dev/null)" ]; then
		pass "user.name / user.email already set"
		return
	fi
	if [ "$MODE" = "check" ]; then
		warn "git identity not set (install.sh asks for it once)"
	elif [ "$DRY" -eq 1 ]; then
		todo "[dry-run] ask for git user.name / user.email"
	elif [ -t 0 ]; then
		local name email
		read -r -p "  git user.name: " name
		read -r -p "  git user.email: " email
		# --file: plain --global would write into the repo's git/config (it is linked as the XDG config)
		git config --file "$HOME/.gitconfig" user.name "$name"
		git config --file "$HOME/.gitconfig" user.email "$email"
		pass "saved in ~/.gitconfig"
	else
		warn "not a terminal: set it later with  git config --file ~/.gitconfig user.name 'Your Name'  (and user.email)"
	fi
}

step_kanata() {
	[ -d "$DOTFILES/kanata" ] || return 0
	say "kanata: machine values (kanata/local.kbd, not tracked)"
	if [ -f "$DOTFILES/kanata/local.kbd" ]; then
		pass "local.kbd exists"
	elif [ "$MODE" = "check" ]; then
		warn "kanata/local.kbd missing: kanata --check will fail until install.sh writes it"
	elif [ "$DRY" -eq 1 ]; then
		todo "[dry-run] write kanata/local.kbd"
	else
		cat >"$DOTFILES/kanata/local.kbd" <<EOF
;; Machine-specific values for config.kbd. Generated from local.kbd.example; not tracked by git.
(defvar
  local-kbd-loaded 1
  user $(id -un)
  cycle-script $DOTFILES/scripts/omniwm-cycle-right.sh
)
EOF
		pass "written for user $(id -un)"
	fi
}

step_nvim() {
	[ "$NVIM" -eq 1 ] || return 0
	say "Neovim: plugins, Mason tools and tree-sitter parsers"
	if ! have nvim; then
		[ "$MODE" = "check" ] && fail "nvim missing" || todo "nvim not available yet"
		return
	fi
	local mason_bin="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"
	if [ "$MODE" = "install" ] && [ "$DRY" -eq 0 ]; then
		echo "  first run downloads a lot (plugins, language servers, parsers): a few minutes"
		nvim --headless "+Lazy! restore" +qa 2>&1 | tail -3
		# mason-tool-installer is configured when nvim-lspconfig loads (first buffer): load it by hand
		nvim --headless "+Lazy! load nvim-lspconfig" "+MasonToolsInstallSync" +qa 2>&1 | tail -3
		nvim --headless "+lua require('nvim-treesitter').install({ 'apex', 'soql', 'sosl', 'sflog', 'html', 'javascript', 'xml', 'regex', 'css', 'java', 'c', 'cpp', 'python' }):wait(300000)" +qa 2>&1 | tail -3
	elif [ "$DRY" -eq 1 ]; then
		todo "[dry-run] Lazy! restore, MasonToolsInstallSync, nvim-treesitter install"
	fi
	local tool
	for tool in lua-language-server typescript-language-server lemminx lwc-language-server prettier eslint_d stylua; do
		[ -e "$mason_bin/$tool" ] && pass "mason: $tool" || { [ "$DRY" -eq 1 ] || warn "mason: $tool not installed (open nvim and run :Mason)"; }
	done
	local jar="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/share/apex-language-server/apex-jorje-lsp.jar"
	[ -e "$jar" ] && pass "mason: apex-jorje-lsp.jar" || { [ "$DRY" -eq 1 ] || warn "mason: apex-language-server not installed"; }
}

# What the author's interactive login shell sees: this is what actually matters.
step_shell_check() {
	say "zsh as you will use it (login + interactive)"
	if [ "$DRY" -eq 1 ]; then
		todo "[dry-run] open zsh -l -i and look for errors and tools"
		return
	fi
	local errs tools t line
	errs="$(zsh -l -i -c exit 2>&1 >/dev/null | grep -v "can't change option: zle" | head -5)"
	[ -z "$errs" ] && pass "starts without errors" || { fail "startup errors:"; echo "$errs" | sed 's/^/        /'; }
	tools="$(zsh -l -i -c 'for t in brew git nvim yazi lazygit starship fzf eza zoxide rg fd jq btop ov mise node sf java; do printf "%s=%s\n" $t "$(command -v $t)"; done' 2>/dev/null)"
	for t in brew git nvim yazi lazygit starship fzf eza zoxide rg fd jq btop ov mise node sf java; do
		line="$(echo "$tools" | grep "^$t=" | head -1)"
		[ "${line#*=}" != "" ] && pass "$t" || fail "$t not found in your shell's PATH"
	done
	if java -version >/dev/null 2>&1; then
		pass "java runs: $(java -version 2>&1 | head -1)"
	else
		warn "java does not run (apex_ls needs it: brew openjdk@21)"
	fi
	if have universal-ctags || (ctags --version 2>&1 | grep -q "Universal Ctags"); then
		pass "universal-ctags"
	else
		warn "ctags is not Universal Ctags (sf.nvim jump to definition)"
	fi
}

# Opens a throw-away sfdx project in headless nvim: filetypes, language servers, formatter, parsers.
step_smoke() {
	[ "$NVIM" -eq 1 ] || return 0
	say "Smoke test: a temporary Salesforce project opened in Neovim"
	if [ "$DRY" -eq 1 ]; then
		todo "[dry-run] sf project generate + headless nvim"
		return
	fi
	have sf && have nvim || { warn "sf or nvim missing, skipped"; return; }
	local tmp
	tmp="$(mktemp -d)"
	(
		cd "$tmp" || exit 1
		sf project generate --name smoke >/dev/null 2>&1 || exit 1
		cd smoke || exit 1
		sf lightning generate component --name hello --type lwc --output-dir force-app/main/default/lwc >/dev/null 2>&1 || exit 1
		printf 'public with sharing class Hello {\n  public static String hi() { return %s; }\n}\n' "'hi'" >force-app/main/default/classes/Hello.cls
		SMOKE_CLS="$PWD/force-app/main/default/classes/Hello.cls" SMOKE_JS="$PWD/force-app/main/default/lwc/hello/hello.js" \
			nvim --headless -c "luafile $DOTFILES/scripts/nvim-smoke.lua" 2>&1 | grep -E '^(PASS|FAIL)'
	) | while IFS= read -r line; do
		case "$line" in
		PASS*) pass "${line#PASS }" ;;
		FAIL*) fail "${line#FAIL }" ;;
		esac
	done
	rm -rf "${tmp:?}"
}

summary() {
	say "Summary"
	printf '  %d failure(s), %d warning(s)\n' "$FAILS" "$WARNS"
	if [ "$MODE" = "install" ] && [ "$DRY" -eq 0 ]; then
		cat <<'EOF'

  Left for you (they need a person):
    - open a new terminal (or: exec zsh -l) so the new shell files take effect
    - gh auth login                      (GitHub CLI)
    - 1Password: turn on the SSH agent   (the SSH config uses its socket)
    - sf org login web --alias <name>    (Salesforce orgs)
    - claude                             (log in; lazygit's <C-a> commit message uses it)
    - kitty: set it as your terminal; the font is JetBrainsMono Nerd Font
EOF
	fi
	[ "$FAILS" -eq 0 ]
}

# ------------------------------------------------------------------------------------------------ run
step_preflight
if [ "$SKIP_BREW" -eq 0 ]; then
	step_xcode
	step_homebrew
	step_packages
else
	refresh_path
fi
step_links
step_ohmyzsh
step_mise
step_git
step_kanata
step_nvim
step_shell_check
step_smoke
summary
