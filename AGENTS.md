# Dotfiles

Windows dev env. Git Bash shell. Track everything important for ephemeral machine.

## Gitignore trap

`/*` deny-by-default. Each new root file/dir needs `!/name` in `.gitignore` or agent changes go untracked. `projects/*` excluded entirely.

## Shell

- `.bashrc` = environment (PATH, exports, secrets sourcing, deferred init). `.bash_aliases` = aliases AND functions (`oc`, `occ`, `ocp`, etc). When cross-porting `.zshrc` content, aliases/functions always go to `.bash_aliases`.
- Secrets sourced from `~/notes/*.env` (private repo, not dotfiles). Sourcing lines in `.bashrc`, env files stay in notes.
- `OPENCODE_DISABLE_AUTOUPDATE=true` (fix plugin re-download bug #8729)

## Naming

- All new files and folders: lowercase-kebab-case (e.g. `90-archive`, `my-file.md`). No PascalCase, no camelCase, no UPPER_CASE unless the surrounding file already uses it.

## Bootstrap

`setup.ps1` — scoop packages, AHK portable, sqlite for nvim, nvim-data backup, fonts, opencode config. Run via `irm raw.githubusercontent.com/jitumaatgit/dotfiles/main/setup.ps1 | iex`.

## Tracked components

| Path | What |
|------|------|
| `AppData/Local/nvim/` | LazyVim neovim config (~46 plugins) |
| `.config/opencode/` | opencode.json + commands + modes + skills |
| `.config/wezterm/` | Git Bash default, Catppuccin Mocha, leader=Ctrl+Space |
| `.config/scoop/` | Scoop config |
| `.config/cagent/` | First-run marker + UUID |
| `.config/blesh/` | ble.sh config (`init.sh`) — **not loaded anymore** |
| `bin/` | Portable executables (keynavish) |
| `.keynavrc` | Keynavish config |
| `mg65.layout.json` | 65% keyboard, 4 layers, numpad on layer 3 |
| `scripts/` | AHK scripts (`toggle_always_on_top.ahk`), `ntfy-client.vbs` hidden launcher |
| `portable-dev/autohotkey-portable/remap-v2.ahk` | CapsLock→Esc, RWin→LCtrl, virtual desktop mgmt |
| `git/` | Git config |
| `.pi/` | Agent settings (excludes everything except `agent/settings.json` + `auth.json`) |
| `setup*.ps1*` | Bootstrap + data backup scripts |
| `scoop/persist/btop/btop.conf` | Btop config |
| `AppData/Roaming/ntfy/client.yml` | ntfy client subscription config (Windows read path) |

## Neovim (LazyVim)

Entry: `AppData/Local/nvim/init.lua`. Plugins in `lua/plugins/*.lua` (numbered for load order, `99.lua` last). `extend-*.lua` patches LazyVim defaults.

Custom modules:
- `weekly-note.lua` — `:ObsidianWeekly [date]`. Vault `C:/Users/student/notes`. Daily notes `docs/30-DailyNotes/YYYY/MM/YYYY-MM-DD.md`
- `task-auto-complete.lua` — On BufWritePost `*.md`, moves `- [x]` tasks to `## Completed` above `## Canceled`
- `obsidian-task-filter/` — `:ObsidianTasksByTag [tags]`

SQLite DLL at `AppData/Local/nvim/bin/sqlite3.dll` (yanky).

## Keynavish

Exe at `bin/keynavish.exe`. Config at `~/.keynavrc`. Layer on defaults (no `clear`). Activation: Ctrl+;. Grid: 1-9 for 3x3 cell-select, 0 for history-back. Auto-start via `HKCU\...\Run` (setup.ps1 sets it).

## ntfy (notification client, cross-port from tablet)

Persistent subscriber to `ntfy.sh` topic `shift-automator-doomax`; shows Windows toast on each message. Ported from the tablet's setup (captured in `notes/handoff/ntfy-tablet-setup-2026-07-11.md` + `notes/docs/20-resources/ntfy-setup.md`). The tablet used apt + a systemd user service + `notify-send`; none of those exist on Windows, so the adaptation:

| concern | tablet (Debian) | windows |
|---|---|---|
| install | apt from `archive.ntfy.sh` (NOT Debian's `dschep/ntfy` imposter) | `scoop install ntfy snoretoast` (extras bucket). Same upstream `binwiederhier/ntfy` v2.26.0. |
| config path | `~/.config/ntfy/client.yml` | `%AppData%\ntfy\client.yml` (ntfy's Windows read path; tracked at `AppData/Roaming/ntfy/client.yml`) |
| env-var syntax in `command:` | bash `$NTFY_TITLE` / `$m` | cmd `%NTFY_TITLE%` / `%NTFY_MESSAGE%` |
| toast command | `notify-send "$title" "$message"` (libnotify) | `snoretoast -t "%NTFY_TITLE%" -m "%NTFY_MESSAGE%"` (scoop extras) |
| exit-code normalization | notify-send exits 0 | snoretoast exits 3 on success (shown, no click) → ntfy logs `Command failed: exit status 3`. MUST append `exit /b 0` after snoretoast in the `command:` block (matches ntfy docs' Windows `notifu` example). |
| auto-start | `systemctl --user enable --now ntfy-client` | `scripts/ntfy-client.vbs` (hidden launcher, window style 0) registered in `HKCU\...\Run` as `ntfy-client`. setup.ps1 sets it + starts the daemon if the VBS exists. |

OS-specific (no Windows analog, knowledge note only): the apt repo signing key at `/etc/apt/keyrings/ntfy.gpg`, `/etc/apt/sources.list.d/ntfy.list`, the `dschep/ntfy` vs `binwiederhier/ntfy` apt-name collision warning, and the systemd unit file. These matter only when reinstalling on the tablet.

Footguns:
- snoretoast requires a registered AppID (Start Menu shortcut). First run auto-registers `Snore.DesktopToasts.0.9.0`; subsequent toasts use it. Omit `-appID` in the config to use the self-registered one (passing `-appID ntfy` without a registered `ntfy` shortcut still shows toasts but is inconsistent — prefer omit).
- The daemon is a console app. Never launch via a bare `HKCU\...\Run` value pointing at `ntfy.exe` — it flashes a console window on login. Always go through the hidden VBS wrapper.
- Config arrives via `git checkout` (it's in the repo), AFTER `setup.ps1` on a fresh bootstrap. setup.ps1 registers the Run key and starts the daemon only if `scripts/ntfy-client.vbs` already exists; otherwise it notes "starts on next login".
- Verify: `ntfy pub --title="test" shift-automator-doomax "hi"` → toast should pop with no `Command failed` log. `ntfy subscribe --from-config --poll` fetches backlog without staying open.
- Adding topics: edit `AppData/Roaming/ntfy/client.yml` under `subscribe:`, then restart the daemon (kill `ntfy.exe`, re-run the VBS).

## WezTerm

Default shell: Git Bash. Catppuccin Mocha. Cascadia Code / JetBrains Mono. Leader key: Ctrl+Space. Vim-style pane nav. `utils.lua` for shared helpers.

## AHK Remaps

`remap-v2.ahk` portable. CapsLock→Esc, RWin→LCtrl. Virtual desktop: Win+1-9 switch, Win+Shift+1-9 move+follow, Win+Alt+1-9 move only, Win+Shift+P pin. Startup shortcut via setup.ps1.

## OpenCode

- `OPENCODE_DISABLE_AUTOUPDATE=true` (fix plugin re-download bug #8729)

### Compaction → handoff gate

Before invoking the `compress` tool for ANY reason (DCP nudge, manual compaction, context-pressure cleanup), you MUST first ask: "Want to /handoff first?" If the user says yes, invoke the handoff skill (`C:\Users\student\.agents\skills\handoff\SKILL.md`) before compressing. If they say no, proceed with compression immediately.

## ble.sh — REMOVED from shell init (2026-07-01)

ble.sh was adding ~0.12s to bash startup and ~0.77s total init time (sourcing 29K lines / 1.1MB). Replaced with native bash readline + fzf keybindings + starship prompt, all deferred to first `PROMPT_COMMAND`. Shell startup dropped from 1.12s to ~0.35s.

The ble.sh source at `~/scripts/blesh/` and config at `.config/blesh/init.sh` are still installed but no longer loaded. If reactivating, the perf config in `init.sh` (syntax highlighting off, auto-complete off, history sharing off) should be kept.

- `edit-and-execute-command` (edit current line in `$EDITOR`) works in emacs mode via `C-x C-e` without ble.sh.
- `C-r` for history search is provided by fzf keybindings (loaded on first prompt).

## Rust (scoop)

- No-admin path: `rustup default stable-x86_64-pc-windows-gnu` uses the `gcc` Scoop package instead of VS Build Tools.
- Scoop `rustup` installs `rustup-init.exe` to `apps/rustup/current/` but creates no shim. The `rustup.exe` proxy lives in `scoop/persist/rustup/.cargo/bin/` — add that to PATH, not `~/.cargo/bin`.
- Prefer `CARGO_HOME`/`RUSTUP_HOME` env vars over symlinks to point rustup at Scoop persist dirs. Git Bash symlinks on Windows are unreliable (may need admin).

## Scoop

`scoop update` self-updates and pulls buckets via git. Two things break it under this setup:

1. **Dotfiles repo dirty** — `~/.config/scoop/config.json` is tracked; scoop rewrites `last_update` on every run → dirty worktree → `git pull` (rebase) refused in the home repo. Fix: `git update-index --skip-worktree .config/scoop/config.json`.
2. **`pull.rebase=true` leaks into scoop's internal repos** — global `~/.gitconfig` sets `pull.rebase = true`; scoop's `apps/*/current` and `buckets/*` repos inherit it, so any spurious diff (e.g. CRLF on a bucket file) blocks scoop's own `git pull` with "cannot pull with rebase: unstaged changes". Fix: path-scoped override.

Path-scoped rebase override (files added to repo):
- `~/scoop-gitconfig` — `[pull] rebase = false`
- `~/.gitconfig` — appended:
  ```
  [includeIf "gitdir:C:/Users/student/scoop/"]
      path = ~/scoop-gitconfig
  ```
- `.gitignore` — `!/scoop-gitconfig` (deny-by-default repo)
- Effect: inside `~/scoop/**` → `pull.rebase = false`; everywhere else → `true` (verified via `git -C <dir> config --get pull.rebase`).

Notes:
- A phantom CRLF diff on a bucket file once blocked updates — `git -C ~/scoop/buckets/<name> checkout -- <file>` to discard. Recurs if the bucket has a `.gitattributes` mismatch; the rebase override above prevents it from blocking updates rather than fixing the root CRLF issue.
- `--skip-worktree` keeps the file tracked but invisible to `git status`/`git pull`; `git diff` may still show the delta — that's harmless. Undo with `git update-index --no-skip-worktree <path>` (note git path is repo-relative).

## Windows gotchas

- Git Bash root: `/c/Users/student`. Use `/c/` paths, not `C://`.
- `.bashrc` fixes `init.lua` shell path escaping for Git Bash

## GitHub CLI (`gh`) quirks

- `gh search commits` only indexes commit **messages**, not file content within commits. Use `gh api repos/.../commits?per_page=N` and iterate patches instead.
- `gh api repos/.../commits` defaults to `per_page=30`, not 100. The initial listing may miss commits. Use `per_page=100` or supply the SHA directly.
- `gh search code` is case-sensitive. A repo may not be indexed immediately — commits may not show up in search results.
