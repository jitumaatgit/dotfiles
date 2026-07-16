# Some useful aliases.
# Sourced by ~/.bashrc (bash-doc pattern — see /usr/share/doc/bash/examples/startup-files/Bash_aliases)

alias oc='opencode'
occ() {
  # OPENCODE_SERVER_PASSWORD (exported by OpenCode Desktop for its sidecar) breaks
  # `opencode run` — the local run path doesn't authenticate, so session creation
  # fails with "Unauthorized: Header of type `authorization` was missing". Strip it
  # for this invocation only.
  local _pw="$OPENCODE_SERVER_PASSWORD"
  unset OPENCODE_SERVER_PASSWORD
  if [ $# -gt 0 ]; then
    opencode run "$@"
  else
    opencode run --command commit
  fi
  OPENCODE_SERVER_PASSWORD="$_pw"
}
function ocp {
  if [ $# -gt 0 ]; then
    opencode --prompt "$*"
    return
  fi
  mkdir -p ~/notes/90-archive/prompts
  local f="$HOME/notes/90-archive/prompts/$(date +%Y%m%d-%H%M%S).md"
  ${EDITOR:-nvim} "$f"
  [ -s "$f" ] || return
  local p="$(command awk 'NR==1 && /^---$/{f=1; next} f && /^---$/{f=0; next} !f' "$f")"
  [ -n "$p" ] || return
  opencode --prompt "$p"
}
alias ls='eza -a'
alias grep='rg --color=auto'
alias lg='lazygit'
alias cd='z'
alias zi='z -i'
alias i='z -i'
alias cat='bat'
alias preview='bat --style=plain --paging=always'
command -v nvim >/dev/null && alias vim='nvim'
