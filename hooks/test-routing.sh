#!/usr/bin/env bash
# Self-check for session-end activity routing. Run: bash hooks/test-routing.sh
set -euo pipefail

HOOK="$(cd "$(dirname "$0")" && pwd)/session-end"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

mkdir -p "$T/vault/team/Tester" "$T/home/.claude-office"
cat > "$T/home/.claude-office/identity.json" <<EOF
{"name":"Tester","vault":"$T/vault","routes":{
  "$T/work":"work",
  "$T/work/loci":"work/loci",
  "$T/secret":"../../escape"
}}
EOF

run() { # <session dir>
  local dir="$1" id="s$RANDOM"
  printf '{"type":"user","timestamp":"2026-01-01T10:00:00Z","cwd":"%s","message":{"content":"a prompt"}}\n' \
    "$T/$dir" > "$T/$id.jsonl"
  rm -f "$T/home/.claude-office/last-session-state.json"
  printf '{"transcript_path":"%s","session_id":"%s","cwd":"%s"}' "$T/$id.jsonl" "$id" "$T/$dir" \
    | HOME="$T/home" bash "$HOOK"
}

expect() { # <relative path under team/Tester>
  [ -f "$T/vault/team/Tester/$1" ] || { echo "FAIL: expected $1"; exit 1; }
}

run "work/loci/api"    # longest prefix wins, subfolder inherits
expect "activity/work/loci/activity-api.md"

run "work/batman"      # shorter prefix still applies
expect "activity/work/activity-batman.md"

run "elsewhere/thing"  # no route -> flat activity dir
expect "activity/activity-thing.md"

run "secret/x"         # ".." in config cannot escape the activity dir
expect "activity/escape/activity-x.md"
[ -z "$(find "$T/vault" -name 'activity-x.md' -not -path '*/activity/*')" ] || { echo "FAIL: escaped activity dir"; exit 1; }

echo "routing OK"
