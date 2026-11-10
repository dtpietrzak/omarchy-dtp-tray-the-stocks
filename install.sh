#!/usr/bin/env bash
# Move the stock status buttons (agents, bluetooth, wifi, sound, display) off
# the bar's right side and into the system tray's drawer, so they show only
# when the tray opens. Safe to run again: buttons already in the drawer are
# left alone.
#
#   ./install.sh          move them into the drawer
#   ./install.sh --undo   put them back on the bar, after the tray

set -euo pipefail

CONFIG="$HOME/.config/omarchy/shell.json"
# In the order they show in the drawer.
IDS='["omarchy.agents","omarchy.bluetooth","omarchy.network","omarchy.audio","omarchy.monitor"]'

fail() {
  echo "install: $*" >&2
  exit 1
}

mode=in
case "${1:-}" in
  -h | --help)
    echo "Usage: install.sh [--undo]"
    echo "Moves agents, bluetooth, wifi, sound and display into the tray's drawer."
    echo "  --undo   Put them back on the bar's right side."
    exit 0
    ;;
  --undo) mode=out; shift ;;
esac
[[ $# -eq 0 ]] || fail "unknown argument: $1"

command -v jq >/dev/null || fail "jq is required"
[[ -f $CONFIG ]] || fail "$CONFIG does not exist. Open the bar settings once so Omarchy writes it, then run this again."
jq -e '.bar.layout' "$CONFIG" >/dev/null || fail "$CONFIG has no bar layout"

# Each button keeps its own settings; only its place changes.
filter='
  def isstock: (.id) as $i | $ids | index($i) != null;
  .bar.layout.right = (.bar.layout.right // []) | .bar.layout.tray = (.bar.layout.tray // [])
  | if $mode == "in" then
      ([.bar.layout.right[] | select(isstock)] + [.bar.layout.tray[] | select(isstock | not)] ) as $moved
      | .bar.layout.right |= map(select(isstock | not))
      | .bar.layout.tray = ([.bar.layout.tray[] | select(isstock)] as $already
          | ($already + ($moved | map(select(.id as $m | ($already | map(.id) | index($m)) == null))))
          | sort_by(.id as $i | $ids | index($i)) ) + [.bar.layout.tray[] | select(isstock | not)]
    else
      ([.bar.layout.tray[] | select(isstock)]) as $back
      | .bar.layout.tray |= map(select(isstock | not))
      | .bar.layout.right as $right
      | (($right | map(.id) | index("omarchy.tray")) // -1) as $at
      | .bar.layout.right = ($right[: $at + 1] + $back + $right[$at + 1 :])
    end'

new="$(jq --argjson ids "$IDS" --arg mode "$mode" "$filter" "$CONFIG")"
if [[ "$new" == "$(jq . "$CONFIG")" ]]; then
  echo "Already set"
  exit 0
fi
cp "$CONFIG" "$CONFIG.bak.$(date +%s)"
printf '%s\n' "$new" >"$CONFIG.tmp"
mv "$CONFIG.tmp" "$CONFIG"
if [[ $mode == in ]]; then
  echo "Moved agents, bluetooth, wifi, sound and display into the tray's drawer"
else
  echo "Put the buttons back on the bar"
fi
