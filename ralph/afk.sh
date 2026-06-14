#!/bin/bash
set -eo pipefail

# Workaround for opencode bug #24747: run fails when OPENCODE_SERVER_PASSWORD is set
unset OPENCODE_SERVER_PASSWORD

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
prompt=$(cat "$script_dir/prompt.md")

for ((i=1; i<=$1; i++)); do
  echo "=== Ralph iteration $i of $1 ==="

  issues=$(gh issue list \
    --state open \
    --label ready-for-agent \
    --json number,title,body \
    --jq '[.[] | "### Issue #\(.number)\n**\(.title)**\n\n\(.body)\n\n---"] | join("\n")' 2>/dev/null || echo "No issues found")

  commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")

  result=$(opencode run \
    --dangerously-skip-permissions \
    --model opencode-go/kimi-k2.6 \
    "Previous commits: $commits Issues: $issues $prompt" 2>&1)

  echo "$result"

  if echo "$result" | grep -q "NO MORE TASKS"; then
    echo "Ralph complete after $i iterations."
    exit 0
  fi
done

echo "Ralph finished $1 iterations. Some tasks may remain."
