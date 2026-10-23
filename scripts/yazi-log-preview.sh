#!/bin/sh
# ~/dotfiles/scripts/yazi-log-preview.sh
# yazi previewer (through piper) for *.log files, with colors (through bat, its "log" syntax).
# Usage: yazi-log-preview.sh <file> [preview height]
#   Salesforce debug log (first line looks like "64.0 APEX_CODE,DEBUG;..."): only the USER_DEBUG, EXCEPTION and
#   FATAL lines, since the rest is thousands of lines of noise. USER_DEBUG is painted green, errors red.
#   Any other log: its last lines, because the recent ones are what matters.
# POSIX sh, so it also works on Linux (where bat can be called batcat). Without bat the output has no colors.

file=$1
height=${2:-30}

# Colorize stdin with bat; plain text if bat is not installed
colorize() {
	bat=$(command -v bat || command -v batcat)
	if [ -n "$bat" ]; then
		"$bat" -p --color=always -l log
	else
		cat
	fi
}

if head -n 1 "$file" | grep -q 'APEX_CODE'; then
	esc=$(printf '\033')
	{ grep -E 'USER_DEBUG|EXCEPTION|FATAL' "$file" || echo '(no USER_DEBUG / EXCEPTION / FATAL lines)'; } |
		colorize |
		sed -E -e "s/USER_DEBUG/${esc}[1;32m&${esc}[0m/" -e "s/(EXCEPTION[A-Z_]*|FATAL[A-Z_]*)/${esc}[1;31m&${esc}[0m/"
else
	tail -n "$height" "$file" | colorize
fi
