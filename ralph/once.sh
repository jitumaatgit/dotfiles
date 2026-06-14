#!/bin/bash
set -eo pipefail

# Workaround for opencode bug #24747: run fails when OPENCODE_SERVER_PASSWORD is set
unset OPENCODE_SERVER_PASSWORD

issues=$(gh issue list \
  --state open \
  --label ready-for-agent \
  --json number,title,body \
  --jq '[.[] | "### Issue #\(.number)\n**\(.title)**\n\n\(.body)\n\n---"] | join("\n")' 2>/dev/null || echo "No issues found")

commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")
script_dir="$(cd "$(dirname "$0")" && pwd)"
prompt=$(cat "$script_dir/prompt.md")

opencode run \
  --dangerously-skip-permissions \
  --model opencode-go/kimi-k2.6 \
  "Previous commits: $commits

Issues: $issues

$prompt"

