export USER=$USERNAME

[[ $- == *i* ]] && source -- ~/scripts/blesh/ble.sh --attach=none

# vim mode if in interactive shell

if [[ $- == *i* ]]; then # in interactive session
  set -o vi
fi
# Enable mode indicator in prompt
bind 'set show-mode-in-prompt on'

# Insert mode: steady bar cursor (│)
bind 'set vi-ins-mode-string \1\e[6 q\2'

# Normal mode: steady block cursor (█)
bind 'set vi-cmd-mode-string \1\e[2 q\2'

###############################################
# WINDOWS DEV PATHS FOR GIT BASH (MINGW64)
###############################################

# Convert Windows-style paths to Unix paths automatically
winpath() {
  /usr/bin/cygpath -u "$1"
}

# Pre-convert USERPROFILE once to avoid subshells in PATH construction
win_up=$(/usr/bin/cygpath -u "$USERPROFILE")

export PATH="$PATH:$win_up/scoop/apps/git/current/usr/bin/bash.exe"
export PATH="$PATH:/c/google-cloud-sdk/bin"
export PATH="$PATH:$win_up/scoop/shims"
export PATH="$PATH:/c/Users/student/portable-dev/qemu/"
export PATH="$PATH:/usr/bin"

if [ -d "$win_up/scoop/apps/go/current/bin" ]; then
  export PATH="$PATH:$win_up/scoop/apps/go/current/bin"
fi

if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$PATH:$HOME/.cargo/bin"
fi

if [ -d "$win_up/.local/bin" ]; then
  export PATH="$PATH:$win_up/.local/bin"
fi

if [ -d "$HOME/AppData/Roaming/npm" ]; then
  export PATH="$PATH:$HOME/AppData/Roaming/npm"
fi

export PATH="$PATH:$HOME/bin"
###############################################
# TERMINAL + NEOVIM FIXES
###############################################

# Proper terminal type for neovim + fzf + lazyvim
export TERM=xterm-256color

# Fix display issues in nvim inside Git Bash
export COLORTERM=truecolor

# Set COLUMNS for proper ls formatting in Git Bash + WezTerm
export COLUMNS=80

###############################################
# OPTIONAL QUALITY OF LIFE
###############################################
# start free-coding-models to pick default model for plan mode before opencode starts
alias oc='free-coding-models --opencode --premium'
# use eza instead of ls
alias ls='eza -a'
# Colorize grep, use rg, etc.
alias grep='rg --color=auto'
# make lg = lazygit
alias lg='lazygit'
# zoxide (smart cd) — lazy-loaded on first use
z() {
  unset -f z
  eval "$(zoxide init bash)"
  z "$@"
}
alias cd='z'
alias zi='z -i'
alias i='z -i'
# bat (cat with syntax highlighting)
alias cat='bat'
alias preview='bat --style=plain --paging=always'
# Make vim = nvim
command -v nvim >/dev/null && alias vim='nvim'
# make neovim default editor (use wrapper for opencode integration)
export EDITOR="nvim"
export VISUAL="wezterm start -- nvim"
# have starship set window title
function set_win_title() {
  echo -ne "\033]0; $(basename "$PWD") \007"
}
starship_precmd_user_func="set_win_title"

###############################################
# OPENCODE PLUGIN PERFORMANCE FIX
# Disables aukto-update to prevent re-downloading
# plugins on every startup (GitHub issue #8729)
###############################################
export OPENCODE_DISABLE_AUTOUPDATE=true

###############################################
# Secrets (tracked in ~/notes repo)
###############################################
[ -f ~/notes/opencode-server.env ] && . ~/notes/opencode-server.env # opencode-server-env
[ -f ~/notes/deepseek.env ] && . ~/notes/deepseek.env               # deepseek-api-key

[ -f ~/.free-coding-models.env ] && . ~/.free-coding-models.env # free-coding-models-env

# starship — lazy-loaded via ble.sh precmd hook
__starship_lazy() {
  unset -f __starship_lazy
  eval "$(starship init bash)"
}
blehook PRECMD+=__starship_lazy
[[ ! ${BLE_VERSION-} ]] || ble-attach
