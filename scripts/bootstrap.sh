#!/usr/bin/env bash
# Bootstrap a new Mac for the Neovim + Salesforce setup in these dotfiles.
#
#   scripts/bootstrap.sh            install everything, then run the checks
#   scripts/bootstrap.sh install    same as above
#   scripts/bootstrap.sh check      only verify (safe to run any time, changes nothing)
#
# Idempotent: every step skips what is already done.
# Testing without touching your real config: XDG_CONFIG_HOME / XDG_DATA_HOME / XDG_STATE_HOME / XDG_CACHE_HOME
# are honoured, and SKIP_BREW=1 skips the Homebrew step.
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_DIR="$DOTFILES/nvim"
MODE="${1:-install}"

FAILS=0
WARNS=0
say() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
pass() { printf '  \033[32mPASS\033[0m %s\n' "$*"; }
warn() { printf '  \033[33mWARN\033[0m %s\n' "$*"; WARNS=$((WARNS + 1)); }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$*"; FAILS=$((FAILS + 1)); }

# ---------------------------------------------------------------------------------------------------
install_xcode_clt() {
	say "Xcode Command Line Tools (C compiler for tree-sitter parsers and LuaSnip)"
	if xcode-select -p >/dev/null 2>&1; then
		pass "already installed"
	else
		xcode-select --install
		echo "Finish the installer dialog, then run this script again."
		exit 1
	fi
}

install_homebrew() {
	say "Homebrew"
	if [ -z "${BREW:-}" ]; then
		for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && BREW="$b" && break; done
	fi
	if [ -z "${BREW:-}" ]; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
		for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && BREW="$b" && break; done
	fi
	eval "$("$BREW" shellenv)"
	pass "$(brew --version | head -1)"
}

install_packages() {
	say "brew bundle ($DOTFILES/scripts/Brewfile)"
	brew bundle --file "$DOTFILES/scripts/Brewfile"
}

link_config() {
	say "Linking nvim -> $CONFIG_HOME/nvim"
	mkdir -p "$CONFIG_HOME"
	local target="$CONFIG_HOME/nvim"
	if [ -L "$target" ] && [ "$(readlink "$target")" = "$NVIM_DIR" ]; then
		pass "already linked"
		return
	fi
	if [ -e "$target" ] || [ -L "$target" ]; then
		local backup="$target.bak-$(date +%Y%m%d%H%M%S)"
		mv "$target" "$backup" && warn "existing config moved to $backup"
	fi
	ln -s "$NVIM_DIR" "$target" && pass "linked"
}

# Needs the JDK on PATH for the Apex language server: .zshrc already does that for openjdk@21 on brew.
bootstrap_nvim() {
	say "Neovim plugins (lazy.nvim restore: honours lazy-lock.json)"
	nvim --headless "+Lazy! restore" +qa 2>&1 | tail -5

	say "Mason: language servers, linters, formatters (a few minutes the first time)"
	# mason-tool-installer is configured when nvim-lspconfig loads (first buffer), so load it by hand.
	nvim --headless "+Lazy! load nvim-lspconfig" "+MasonToolsInstallSync" +qa 2>&1 | tail -15

	say "Tree-sitter parsers"
	nvim --headless "+lua require('nvim-treesitter').install({ 'apex', 'soql', 'sosl', 'sflog', 'html', 'javascript', 'xml', 'regex', 'css', 'java', 'c', 'cpp', 'python' }):wait(300000)" +qa 2>&1 | tail -5
}

# ---------------------------------------------------------------------------------------------------
need() { # need <command> <hint>
	if command -v "$1" >/dev/null 2>&1; then pass "$1  ($(command -v "$1"))"; else fail "$1 missing - $2"; fi
}

version_ge() { # version_ge 24.1.0 20  -> true if the first major >= the second
	[ "${1%%.*}" -ge "$2" ] 2>/dev/null
}

check_tools() {
	say "Command line tools"
	need git "brew install git"
	need rg "brew install ripgrep"
	need fd "brew install fd"
	need fzf "brew install fzf"
	need tree-sitter "brew install tree-sitter-cli"
	need cc "xcode-select --install"
	need npm "brew install node"
	need sf "brew install sf   (the cask is disabled)"

	if command -v nvim >/dev/null 2>&1; then
		local v
		v="$(nvim --version | head -1 | sed -E 's/NVIM v([0-9]+\.[0-9]+).*/\1/')"
		if [ "$(printf '%s\n0.12\n' "$v" | sort -V | head -1)" = "0.12" ]; then pass "nvim $v"; else fail "nvim $v (< 0.12)"; fi
	else
		fail "nvim missing - brew install neovim"
	fi

	if command -v node >/dev/null 2>&1; then
		local nv
		nv="$(node -v | tr -d v)"
		if version_ge "$nv" 20; then pass "node $nv"; else fail "node $nv (< 20)"; fi
	fi

	# macOS ships /usr/bin/java as a stub that fails, so run it instead of just looking for it.
	if java -version >/dev/null 2>&1; then
		pass "java: $(java -version 2>&1 | head -1)"
	else
		fail "java does not run - brew install openjdk@21 and put /opt/homebrew/opt/openjdk@21/bin on PATH (.zshrc does)"
	fi

	if command -v ctags >/dev/null 2>&1 && ctags --version 2>&1 | grep -q "Universal Ctags"; then
		pass "universal-ctags"
	else
		warn "ctags is not Universal Ctags (jump-to-definition fallback in sf.nvim) - brew install universal-ctags"
	fi
	command -v watchman >/dev/null 2>&1 && pass "watchman" || warn "watchman missing (Jest is slower on big projects)"
}

check_sf_cli() {
	say "Salesforce CLI"
	command -v sf >/dev/null 2>&1 || return
	pass "$(sf --version 2>/dev/null | head -1)"
	local orgs
	orgs="$(sf org list --json 2>/dev/null | jq '[.result[]?[]?] | length' 2>/dev/null || echo 0)"
	if [ "${orgs:-0}" -gt 0 ]; then pass "$orgs authorised org(s)"; else warn "no authorised orgs yet - run: sf org login web --alias <name> --set-default"; fi
}

check_mason() {
	say "Mason packages"
	local bin="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"
	for tool in lua-language-server typescript-language-server lemminx lwc-language-server prettier eslint_d stylua; do
		[ -e "$bin/$tool" ] && pass "$tool" || fail "mason: $tool not installed - open nvim and run :Mason"
	done
	local jar="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/share/apex-language-server/apex-jorje-lsp.jar"
	[ -e "$jar" ] && pass "apex-jorje-lsp.jar" || fail "mason: apex-language-server not installed"
}

# Creates a throw-away sfdx project (local only: no org needed) and opens it in headless nvim.
smoke_test() {
	say "Smoke test in a temporary Salesforce project"
	command -v sf >/dev/null 2>&1 || { fail "sf missing, skipped"; return; }
	local tmp
	tmp="$(mktemp -d)"
	(
		cd "$tmp" || exit 1
		sf project generate --name smoke >/dev/null 2>&1 || exit 1
		cd smoke || exit 1
		sf lightning generate component --name hello --type lwc \
			--output-dir force-app/main/default/lwc >/dev/null 2>&1 || exit 1
		printf 'public with sharing class Hello {\n  public static String hi() { return %s; }\n}\n' "'hi'" \
			>force-app/main/default/classes/Hello.cls
		SMOKE_CLS="$PWD/force-app/main/default/classes/Hello.cls" \
			SMOKE_JS="$PWD/force-app/main/default/lwc/hello/hello.js" \
			nvim --headless -u "$CONFIG_HOME/nvim/init.lua" -c "luafile $DOTFILES/scripts/nvim-smoke.lua" 2>&1 |
			grep -E '^(PASS|FAIL)'
	) | while IFS= read -r line; do
		case "$line" in
		PASS*) pass "${line#PASS }" ;;
		FAIL*) fail "${line#FAIL }" ;;
		esac
	done
	[ "${PIPESTATUS[0]:-0}" -eq 0 ] || fail "could not create the temporary project"
	rm -rf "$tmp"
}

summary() {
	say "Summary"
	printf '  %d failure(s), %d warning(s)\n' "$FAILS" "$WARNS"
	[ "$FAILS" -eq 0 ]
}

# ---------------------------------------------------------------------------------------------------
case "$MODE" in
install)
	install_xcode_clt
	if [ -z "${SKIP_BREW:-}" ]; then
		install_homebrew
		install_packages
	fi
	link_config
	bootstrap_nvim
	check_tools
	check_sf_cli
	check_mason
	smoke_test
	summary
	;;
check)
	check_tools
	check_sf_cli
	check_mason
	smoke_test
	summary
	;;
*)
	echo "usage: $0 [install|check]" >&2
	exit 2
	;;
esac
