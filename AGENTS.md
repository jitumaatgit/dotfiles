# Dotfiles

Windows dev env. Git Bash shell. Track everything important for ephemeral machine.

## Gitignore trap

`/*` deny-by-default. Each new root file/dir needs `!/name` in `.gitignore` or agent changes go untracked. `projects/*` excluded entirely.

## Shell (.bashrc)

- `oc` alias → `free-coding-models` + `opencode`
- Secrets sourced from `~/notes/*.env` (private repo, not dotfiles). Sourcing lines in `.bashrc`, env files stay in notes.
- `OPENCODE_DISABLE_AUTOUPDATE=true` (fix plugin re-download bug #8729)

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
| `bin/` | Portable executables (keynavish) |
| `.keynavrc` | Keynavish config |
| `mg65.layout.json` | 65% keyboard, 4 layers, numpad on layer 3 |
| `scripts/` | AHK scripts (`toggle_always_on_top.ahk`) |
| `portable-dev/autohotkey-portable/remap-v2.ahk` | CapsLock→Esc, RWin→LCtrl, virtual desktop mgmt |
| `git/` | Git config |
| `.pi/` | Agent settings (excludes everything except `agent/settings.json` + `auth.json`) |
| `setup*.ps1*` | Bootstrap + data backup scripts |
| `scoop/persist/btop/btop.conf` | Btop config |

## Neovim (LazyVim)

Entry: `AppData/Local/nvim/init.lua`. Plugins in `lua/plugins/*.lua` (numbered for load order, `99.lua` last). `extend-*.lua` patches LazyVim defaults.

Custom modules:
- `weekly-note.lua` — `:ObsidianWeekly [date]`. Vault `C:/Users/student/notes`. Daily notes `docs/30-DailyNotes/YYYY/MM/YYYY-MM-DD.md`
- `task-auto-complete.lua` — On BufWritePost `*.md`, moves `- [x]` tasks to `## Completed` above `## Log`
- `obsidian-task-filter/` — `:ObsidianTasksByTag [tags]`

SQLite DLL at `AppData/Local/nvim/bin/sqlite3.dll` (yanky).

## Keynavish

Exe at `bin/keynavish.exe`. Config at `~/.keynavrc`. Layer on defaults (no `clear`). Activation: Ctrl+;. Grid: 1-9 for 3x3 cell-select, 0 for history-back. Auto-start via `HKCU\...\Run` (setup.ps1 sets it).

## WezTerm

Default shell: Git Bash. Catppuccin Mocha. Cascadia Code / JetBrains Mono. Leader key: Ctrl+Space. Vim-style pane nav. `utils.lua` for shared helpers.

## AHK Remaps

`remap-v2.ahk` portable. CapsLock→Esc, RWin→LCtrl. Virtual desktop: Win+1-9 switch, Win+Shift+1-9 move+follow, Win+Alt+1-9 move only, Win+Shift+P pin. Startup shortcut via setup.ps1.

## OpenCode

- **`opencode run` fails "Session not found" when `OPENCODE_SERVER_PASSWORD` is set** (bug #24747). Desktop exports this env var for its sidecar server; child shells inherit it. The local run path enables auth but doesn't authenticate, breaking session creation. Must `unset OPENCODE_SERVER_PASSWORD` — setting to empty string doesn't work.
- `OPENCODE_DISABLE_AUTOUPDATE=true` (fix plugin re-download bug #8729)

## Windows gotchas

- Git Bash root: `/c/Users/student`. Use `/c/` paths, not `C://`.
- `.bashrc` fixes `init.lua` shell path escaping for Git Bash
