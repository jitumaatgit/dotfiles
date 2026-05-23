# Neovim Config (LazyVim)

Dotfiles repo with a LazyVim-based Neovim configuration under `AppData/Local/nvim/`.

## Structure

| Directory | Purpose |
|-----------|---------|
| `lua/plugins/` | 46 lazy.nvim plugin specs — each returns a table. Override LazyVim defaults here. |
| `lua/config/` | Core config: `lazy.lua` (bootstrap), `options.lua`, `keymaps.lua`, `autocmds.lua` |
| `lua/custom/` | Hand-written modules: `weekly-note.lua`, `task-auto-complete.lua`, `obsidian-task-filter/` |
| `ftplugin/` | Filetype-specific settings (markdown, lua, powershell, etc.) |

## Custom Modules

- **`weekly-note.lua`** — Generates `YYYY-Www.md` weekly notes for obsidian vault. Hardcoded vault path: `C:/Users/student/notes`. Weekly notes go to `docs/30-DailyNotes/WeeklyNotes/<YYYY>/`. Daily note links use `[[30-DailyNotes/YYYY/MM/YYYY-MM-DD|DayName Date]]` format.
- **`task-auto-complete.lua`** — On `BufWritePost` for `*.md`, moves completed `- [x]` tasks (with heading context and timestamp) into a `## Completed` section, placing it above `## Log` for daily notes.
- **`obsidian-task-filter/`** — `:ObsidianTasksByTag [tags]` — searches vault for tasks in files matching all specified tags. Uses telescope picker if available.

## Plugin Conventions

- Plugin specs return a table with `keys`, `opts`, `config`, etc. See `lazy.nvim` docs.
- `enabled = false` to disable a LazyVim default plugin (see `lua/plugins/disabled.lua`).
- Extend-pattern: `extend-*.lua` files override specific LazyVim plugins (e.g., `extend-mini-files.lua` adds obsidian reference updating on file move/rename).
- `99.lua` loads last (numbered prefix ensures sort order in `lua/plugins/`).

## Key Custom Commands

| Command | Source |
|---------|--------|
| `:ObsidianWeekly [date]` | `weekly-note.lua` |
| `:ObsidianWeeklyPrev` / `:ObsidianWeeklyNext` | `weekly-note.lua` |
| `:ObsidianTasksByTag [tags]` | `obsidian-task-filter/init.lua` |

## Vault & Paths

- Vault root: `C:/Users/student/notes`
- Daily notes: `docs/30-DailyNotes/YYYY/MM/YYYY-MM-DD.md`
- Weekly notes: `docs/30-DailyNotes/WeeklyNotes/YYYY/YYYY-Www.md`
- Templates: `docs/50-Templates/`

## Secrets & Env Files

- Sensitive env vars (API keys, passwords) belong in the private `~/notes/` repo, not in dotfiles. Create `~/notes/<name>.env` with `export KEY="value"`, commit to notes, then source from `.bashrc` via `[ -f ~/notes/<name>.env ] && . ~/notes/<name>.env`.
- The sourcing line in `.bashrc` is tracked in dotfiles; the `.env` file itself stays in the private notes repo where it's gitignored from dotfiles by the `/*` denylist rule.

## Git & Repo Quirks

- Root `.gitignore` uses `/*` (ignore everything) + selective `!` un-ignores. Any new file at root MUST be added to `.gitignore` as `!/filename` or it won't be tracked. This silently blocked `AGENTS.md` from being committed.

## Windows Gotchas

- Git Bash is the shell. Use `/c/` paths in bash commands, not `C://`.
- SQLite DLL for yanky.nvim: `AppData/Local/nvim/bin/sqlite3.dll`
- The `init.lua` has a shell path escaping fix for Git Bash on Windows.
