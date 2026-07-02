# Dotfiles — Windows Dev Environment

## Domain

This repo configures a Windows ephemeral dev environment. The machine restores to default on restart/crash, so everything important is tracked in git and restored via `setup.ps1`.

## Shell

- **Terminal:** Git Bash (MINGW64) via WezTerm
- **Bash version:** 5.3.9(1)-release (on Git for Windows)
- **Prompt:** Starship + fzf (deferred to first prompt)
- **Navigation:** zoxide (replaces `cd`)
- **Environment secrets:** sourced from `~/notes/*.env` (private repo)

## Key components

| Component | Config location | Purpose |
|-----------|----------------|---------|
| WezTerm | `.config/wezterm/` | Terminal emulator, leader=Ctrl+Space |
| Neovim | `AppData/Local/nvim/` | LazyVim-based editor (~46 plugins) |
| opencode | `.config/opencode/` | CLI coding agent |
| fzf/Starship | `.bashrc` | Prompt + history search (deferred to first prompt) |
| zoxide | `.bashrc` | Smart cd (lazy-loaded) |
| Scoop | `.config/scoop/` | Windows package manager |
| AHK | `portable-dev/autohotkey-portable/remap-v2.ahk` | CapsLock→Esc, RWin→LCtrl, virtual desktops |
| Keynavish | `bin/keynavish.exe` | Keyboard-driven mouse (Ctrl+;) |
| btop | `scoop/persist/btop/btop.conf` | System monitor |

## Critical conventions

- **Paths:** Use `/c/` not `C://` (Git Bash)
- **Git ignoring:** `.gitignore` uses `/*` deny-by-default — each new root file/dir needs `!/name` to be tracked
- **Bootstrap:** `setup.ps1` installs Scoop packages, AHK, fonts, opencode config
- **Secrets:** Never commit secrets; stored in `~/notes/` (private repo), sourced in `.bashrc`
- **Ephemeral machine:** If it's not in git, it's lost on restart

## Shell performance

- Starship and fzf init deferred to first `PROMPT_COMMAND` (~0.25s savings)
- `zoxide` lazy-loaded on first `z` invocation
- Git Bash/MSYS2 is slow at filesystem operations — avoid subshells (`$(...)`) and external commands in hot paths
- Minibuf shell init: 0.07s; full login startup: ~0.35s (warm)
