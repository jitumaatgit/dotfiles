---
name: responsive-bashrc
description: Write responsive .bashrc and shell init files prioritizing low-latency startup and prompt. Integrates defensive patterns only where they don't conflict with performance or ble.sh §2.3 principles. Use when editing .bashrc, .bash_profile, .profile, .bash_aliases, .bash_functions, or any shell init file.
---

# Responsive Bashrc

## Core principles (priority order)

1. **No subshells in hot paths** — `$()` forks on every prompt. Never in PS1 or prompt hooks.
2. **No external commands in init** — `date`, `which`, `grep`, `sed` at shell start add up. Prefer builtins.
3. **Batch external calls** — one `awk` beats five `sed|grep|cut` pipes.
4. **Avoid unbuffered read** — `while read` over pipes is ~2000x slower than `mapfile` or parameter expansion.
5. **Add defensive patterns last** — only where zero runtime cost.

## Fast vs slow patterns

| Slow (fork-heavy) | Fast (builtin) |
|---|---|
| `$(date)` in PS1 | `printf '%(%T)T' -1` |
| `which cmd` | `command -v cmd` |
| `grep -q p <<< "$var"` | `[[ $var == *p* ]]` |
| `$(<file)` | `read -r var < file` |
| `sed s/// <<< "$var"` | `${var//pattern/replacement}` |
| `tr A-Z a-z <<< "$var"` | `${var,,}` |
| multiple sed/grep/cut pipes | single `awk` script |
| `while read` over pipe | `mapfile` + array loop |
| `type cmd` | `command -v cmd` |

## Zero-cost defensive patterns (always use)

These have no performance impact:
- `set -Eeuo pipefail` — error semantics only
- `[[ ]]` over `[ ]` — builtin, actually faster
- `"$var"` quoting — parse-time safety
- `command -v` over `which` — builtin, no fork
- `printf` over `echo` — portable, no cost

## Templates

### Minimal fast .bashrc

```bash
set -Eeuo pipefail
PATH="$HOME/bin:$PATH"
PS1='\w\$ '
alias ll='ls -la'
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
```

### Lazy loading (defer forks)

```bash
nvm() {
  unset -f nvm
  [[ -f "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}
```

## See [REFERENCE.md](REFERENCE.md)
