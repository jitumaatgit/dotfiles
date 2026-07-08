# Cross-Port Reference

## Repo profiles

| key | windows | tablet |
|---|---|---|
| repo | `jitumaatgit/dotfiles` | `jitumaatgit/tablet-dotfiles` |
| default branch | `main` | `main` |
| shell rc | `.bashrc` sources `.bash_aliases` | `.zshrc` |
| nvim dir | `AppData/Local/nvim/` | `.config/nvim/` |
| opencode dir | `.config/opencode/` | `.config/opencode/` (1:1) |
| deploy script | `setup.ps1` (powershell) | `deploy.sh` + `setup.sh` (bash) |
| dotfiles model | `setup.ps1` restores fresh each boot | bare repo `~/.dotfiles`, alias `dotfiles` |
| skills home | `~/.agents/skills/` (tracked in repo) | `~/.agents/skills/` |
| secrets | `~/notes/*.env` (private repo) | env files, not in repo |
| user | `student` | `fomar` |
| os | git-bash on win32, ephemeral | Debian trixie, Doogee U10 (RK3562) |
| editor | `nvim`; wezterm GUI launcher | `hx` available; `nvim`=vim |
| clipboard | win32yank / system | `wl-clipboard` (Wayland) |
| package mgr | scoop | apt/flatpak/cargo |

## Translation matrix (logical → local path on each system)

| concern | windows path | tablet path |
|---|---|---|
| opencode commands | `.config/opencode/command/*.md` | `.config/opencode/command/*.md` |
| opencode config | `.config/opencode/opencode.json` | `.config/opencode/opencode.json` |
| shell aliases | `.bash_aliases` | `.zshrc` |
| shell functions | `.bashrc` (functions block) | `.zshrc` |
| nvim init | `AppData/Local/nvim/init.lua` | `.config/nvim/init.lua` |
| nvim lua | `AppData/Local/nvim/lua/**/*.lua` | `.config/nvim/lua/**/*.lua` |
| wezterm | `.config/wezterm/` | `.config/wezterm/` |
| AGENTS.md | `AGENTS.md` (repo root) | `AGENTS.md` (repo root) |
| deploy | `setup.ps1` (no analog) | `deploy.sh` (no analog) |
| package mgr | scoop | apt/flatpak/cargo |
| clipboard | win32yank | wl-clipboard |
| editor | `nvim` | `hx` + `nvim` |

## Adaptation rules (needs-adaptation transforms)

### `.zshrc` block ↔ `.bash_aliases`

- alias lines: identical syntax in both
- `name() { ... }` function syntax: identical in zsh and bash
- zsh-only features (`setopt`, `PROMPT` `%`-escapes, `precmd` hooks): **flag to user**, don't silently translate prompt escapes
- arrays: `${array[@]}` works in both; zsh `${array}` (no `[@]`) is a portability trap

### nvim lua

Pure path remap. Content is identical:
- `.config/nvim/<x>` ↔ `AppData/Local/nvim/<x>`

### env-var propagation learning (the bare-repo `occ()` fix)

The tablet's bare-repo model needs `GIT_DIR`/`GIT_WORK_TREE` env vars (not CLI flags) so opencode's spawned git subprocesses inherit them. On windows there is no bare repo, so `occ` stays a plain alias — but the *reasoning* is portable as an AGENTS.md note.

### opencode.json

Merge key-by-key. Do not clobber local-only keys. Known syncable keys:
- `permission.external_directory`
- `server.port`
- MCP remotes
- providers

## Classification rubric

- **portable**: same logical path, same content, both systems have the file (e.g. `.config/opencode/command/commit.md`). Action: overwrite local from remote.
- **needs-adaptation**: same intent, different path or dialect (e.g. shell rc, nvim path). Action: rewrite + write to local target.
- **OS-specific**: only meaningful on one system (e.g. `setup.ps1`, `deploy.sh`, binderfs/Waydroid notes, RK3562 governor scripts). Action: knowledge note only.
- **ambiguous**: ask the user. (e.g. `.bashrc` opcodes that reference Windows paths — definitions of "portable" flip depending on direction.)

## Worked example: the opencode-alias story (reference case)

Commit `ff650b0b` on tablet (`jitumaatgit/tablet-dotfiles`) touched:

| file | class | action on windows |
|---|---|---|
| `init.lua` | needs-adaptation | path remap `.config/nvim` → `AppData/Local/nvim` |
| `lua/plugins/trouble-fetch-fix.lua` | needs-adaptation | same remap |
| `.config/opencode/command/commit.md` | portable | overwrite local — BUT local had diverged ahead (more evolved). Skill must warn, not blind-overwrite. |
| `.zshrc` (oc/occ/ocp functions) | needs-adaptation | → `.bash_aliases` (alias) + `.bashrc` (function) |

The bare-repo `GIT_DIR`/`GIT_WORK_TREE` env propagation fix inside `occ()` is OS-specific to the tablet's bare-repo model → knowledge note in windows AGENTS.md.

Commit `e72867a1` on tablet added `permission.external_directory: allow` to opencode.json → needs-adaptation (merge into local opencode.json, don't clobber).

## gh API cheat sheet

All verified working under `gh auth status` as `jitumaatgit`.

```bash
# list recent commits on a repo
gh api repos/jitumaatgit/tablet-dotfiles/commits --paginate -q '.[].sha'

# one commit's changed files
gh api repos/jitumaatgit/tablet-dotfiles/commits/<sha> -q '.files[] | "\(.status)\t\(.filename)\t+\(.additions)/-\(.deletions)"'

# fetch a file's content (base64-decoded)
gh api repos/jitumaatgit/tablet-dotfiles/contents/<path> -q '.content' | base64 -d

# repo tree (recursive)
gh api repos/jitumaatgit/tablet-dotfiles/git/trees/main?recursive=1 -q '.tree[].path'

# remote-default-branch
gh repo view jitumaatgit/tablet-dotfiles --json defaultBranchRef -q .defaultBranchRef.name
```

## Knowledge note home

OS-specific learnings get written into the local notes repo under:

`docs/20-resources/ai/harness/cross-port/<source-repo>-<sha>-<slug>.md`

Each note frontmatter: `source_repo`, `commit`, `date`, `system_of_origin`. Body quotes the source verbatim with a `file_path:line` link, then a short "why this is OS-specific / why windows doesn't need it" blurb.

> Convention (e.g. lowercase-kebab-case) → AGENTS.md appendix.
> One-off fact (e.g. RK3562 governor quirk) → notes repo.

## Out of scope

- `nixos-dotfiles` (third repo) — future expansion.
- Auto-push / auto-commit — never.
- Overwriting a local file that has diverged ahead of remote without warning — always diff and warn first.