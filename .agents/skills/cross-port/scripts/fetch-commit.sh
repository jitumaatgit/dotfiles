#!/usr/bin/env bash
# fetch-commit.sh <owner/repo> <sha|recent> [N]
# Prints one line per changed file: <status>\t<path>\t<+add/-del>
# Used by cross-port skill to enumerate a commit's touch set.
# For "recent" mode, prefixes each commit's block with "# <sha>".
set -euo pipefail
repo="$1"
mode="${2:-recent}"
n="${3:-10}"

emit() {
  gh api "repos/$repo/commits/$1" \
    -q '.files[] | "\(.status)\t\(.filename)\t+\(.additions)/-\(.deletions)"'
}

if [ "$mode" = "recent" ]; then
  for sha in $(gh api "repos/$repo/commits" --paginate -q ".[0:$n][].sha"); do
    echo "# $sha"
    emit "$sha"
  done
else
  emit "$mode"
fi