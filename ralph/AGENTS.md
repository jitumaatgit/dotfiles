# Ralph — AFK Coding Loop (dotfiles)

## Script path resolution

Scripts must resolve `prompt.md` relative to their own directory, not CWD.

```bash
script_dir="$(cd "$(dirname "$0")" && pwd)"
prompt=$(cat "$script_dir/prompt.md")
```

## Issue integration (GitHub)

Issues fetched via `gh` CLI filtered by `ready-for-agent` label:

```bash
gh issue list --state open --label ready-for-agent --json number,title,body \
  --jq '[.[] | "### Issue #\(.number)\n**\(.title)**\n\n\(.body)\n\n---"] | join("\n")'
```

Completed tasks: `gh issue comment <N>` + `gh issue close <N>`.

## Gitignore trap

`ralph/` must be explicitly ungignored since dotfiles uses `/*` deny-by-default. Requires `!/ralph` and `!/ralph/**` entries in `.gitignore`.

## Feedback loops

`shellcheck` on modified bash scripts; `bash -n` for syntax validation.
