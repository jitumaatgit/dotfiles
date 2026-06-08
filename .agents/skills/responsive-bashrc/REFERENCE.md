# Responsive Bashrc — Reference

## PS1 optimization

PS1 is evaluated before every prompt — any `$()` or external command forks on every keystroke.

```bash
# BAD — forks every prompt
PS1='$(date +%H:%M) \w\$ '

# GOOD — builtin format
PS1='\[\e[1;30m\][\A]\[\e[0m\] \w\$ '
```

Use `PROMPT_COMMAND` sparingly — it runs before every prompt. Batch work into one function:

```bash
# BAD — two PROMPT_COMMAND hooks (two forks)
PROMPT_COMMAND='update_title; check_git_status'

# GOOD — one hook
__prompt() { update_title; check_git_status; }
PROMPT_COMMAND=__prompt
```

## Conditional loading patterns

### Defer completions until first TAB

Don't source completion scripts in `.bashrc`. Bash's `complete -D` lets you register by command name:

```bash
# Instead of:
# source ~/.completions/gh-completion.bash

# Use bash_completion's dynamic loading (it sources on first TAB per command)
[[ -f /usr/share/bash-completion/bash_completion ]] && \
  source /usr/share/bash-completion/bash_completion
```

### Lazy function pattern

Define a shell function that replaces itself on first call:

```bash
fnm() {
  unset -f fnm
  eval "$(fnm env --use-on-cd --shell bash)"
  fnm "$@"
}

# Usage in aliases — first `fnm use` triggers lazy load
alias f=fnm
```

## Fast git status in prompt

Avoid `$(git status --porcelain)` (subshell + external). Use `bash`'s builtin `__git_ps1`:

```bash
# Check if git-prompt.sh exists first (zero-cost check)
if [[ -f /usr/share/git/git-prompt.sh ]]; then
  source /usr/share/git/git-prompt.sh
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  PS1='\w$(__git_ps1 " (%s)") \$ '
fi
```

__git_ps1 is a bash function, not a subshell — it reads `.git/HEAD` directly via builtins.

## File existence checks

```bash
# BAD — forks test
[ -f "$file" ] || echo "missing"

# GOOD — same cost, more readable
[[ -f "$file" ]] || echo "missing"
```

## PATH manipulation without forks

```bash
# BAD — grep in subshell
add_path() { [[ ":$PATH:" == *":$1:"* ]] || PATH="$1:$PATH"; }

# GOOD — builtin pattern match
add_path() { [[ :$PATH: != *:$1:* ]] && PATH="$1:$PATH"; }
```

## History settings

```bash
# BAD — `history -a; history -c; history -r` on every command (reloads all history)
# Use ble.sh's history_share instead:
#   bleopt history_share=1

# GOOD — append only, no reload
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Limit size
HISTFILESIZE=10000
HISTSIZE=5000
```

## Profiling slow shell startup

```bash
# Add to top of .bashrc
__profile_start=$(printf '%(%s)T' -1)

# Add to bottom
echo "bashrc loaded in $(($(printf '%(%s)T' -1) - __profile_start))s"
```

For finer granularity, trace with `$BASH_XTRACED`:

```bash
export BASH_XTRACED=1    # shows timestamps per line
set -x                   # enable trace
# source things...
set +x                   # disable trace
```

## See also

- [ble.sh Performance wiki](https://github.com/akinomyoga/ble.sh/wiki/Performance#23-general-hints-for-responsive-shell-implementation)
