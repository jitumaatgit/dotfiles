---
name: cross-port
description: Port dotfiles changes between the user's Windows (jitumaatgit/dotfiles) and Debian-Trixie tablet (jitumaatgit/tablet-dotfiles) repos. Given a commit SHA, recent commits, or a path scan on the OTHER system, classify each changed file as portable / needs-adaptation / OS-specific, then apply the adapted change locally or write a knowledge note. Use when user says "port X from tablet", "what did the tablet learn that windows lacks", "sync dotfiles", mentions cross-OS dotfile drift, or asks to carry a change from one system to the other.
---

# Cross-Port

## Quick start

```
# port the opencode-alias evolution from tablet to windows
> use cross-port with ff650b0b on jitumaatgit/tablet-dotfiles

# port a recent windows change back to tablet
> use cross-port, recent, from jitumaatgit/dotfiles to jitumaatgit/tablet-dotfiles

# what's in the other repo's AGENTS.md that mine lacks?
> use cross-port scan AGENTS.md
```

## Workflows

### 1. Detect current system

State it explicitly so mis-detection is visible.

```bash
if [ -n "$MSYSTEM" ] || [ "$(uname -s)" = "MINGW64_NT-*" ]; then
  current=windows
elif [ -d "$HOME/.dotfiles" ]; then
  current=tablet
fi
```

### 2. Identify the OTHER repo

Hardcoded pair — windows ↔ tablet (nixos-dotfiles out of scope; see REFERENCE.md).

| current | other repo | other system |
|---|---|---|
| windows | `jitumaatgit/tablet-dotfiles` | Debian trixie tablet (user fomar) |
| tablet | `jitumaatgit/dotfiles` | Windows git-bash (user student) |

Owner is always `jitumaatgit` (NOT `jitumaat` — that 404s).

### 3. Resolve input mode

- `<sha>`: port that one commit from the other repo
- `recent` (default): port the last 10 commits on the other repo's default branch
- `scan <path>`: diff the other repo's working file at `path` vs local

### 4. Fetch changed files

```bash
bash scripts/fetch-commit.sh <other-repo> <sha|recent> [N]
```

Output is one line per file: `<status>\t<path>\t<+n/-n>`. For `scan` mode, use `gh api repos/<repo>/contents/<path>` directly.

### 5. Classify each file

Against the translation matrix in [REFERENCE.md](REFERENCE.md):

- **portable** — same logical path on both systems (e.g. `.config/opencode/command/*.md`). Action: overwrite local from remote.
- **needs-adaptation** — same intent, different path or dialect (e.g. `.zshrc` → `.bash_aliases`, `.config/nvim/` → `AppData/Local/nvim/`). Action: rewrite per adaptation rule, write to local target.
- **OS-specific** — no local analog (e.g. `setup.ps1`, `deploy.sh`, binderfs/Waydroid notes). Action: knowledge note only.

### 6. Act per class

- **portable**: `gh api repos/<repo>/contents/<path> -q .content | base64 -d` → local mirror path. **Before writing**: diff local vs fetched; if local diverged ahead of remote, WARN and ask — never blind-overwrite.
- **needs-adaptation**: fetch remote content, rewrite per adaptation rule (path remap + dialect transform), write to local target. Show the rewrite to the user before writing.
- **OS-specific**: append a knowledge note to local `AGENTS.md` (when the learning is a *convention*) OR create a note in the notes repo under `docs/20-resources/ai/harness/cross-port/<source-repo>-<sha>-<slug>.md` (when it's a one-off *fact*). Quote the other system's source verbatim in the note with a `file_path:line` link.

### 7. Report

Table: `{file, class, action taken, local path written}`. Distinguish applied vs noted. An OS-specific-only commit → "nothing to apply; 1 knowledge note written" so the user knows the commit was examined, not skipped.

### 8. Commit discipline

Never auto-commit (AGENTS.md: only commit when asked). Offer to stage. If user says yes, commit with message `port: <short summary> from <other-repo> <sha>` so the provenance is searchable.

## Advanced features

See [REFERENCE.md](REFERENCE.md) for the full translation matrix, repo profiles, adaptation rules, classification rubric, the opencode-alias worked example, and the gh API cheat sheet.