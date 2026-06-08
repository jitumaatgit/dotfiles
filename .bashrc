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

# start new terminals in insert mode
PROMPT_COMMAND='bind "set vi-ins-mode-string \1\e[6 q\2"; bind -m vi-insert'
###############################################
# WINDOWS DEV PATHS FOR GIT BASH (MINGW64)
###############################################

# Convert Windows-style paths to Unix paths automatically
winpath() {
  /usr/bin/cygpath -u "$1"
}
# bash.exe path
export PATH="$PATH:$(winpath "$USERPROFILE/scoop/apps/git/current/usr/bin/bash.exe")"

# google cloud CLI path
export PATH="$PATH:$(winpath 'C:\google-cloud-sdk\bin')"

# ⭐ Scoop shims (wezterm, nvim, rg, bat, etc.)
export PATH="$PATH:$(winpath "$USERPROFILE/scoop/shims")"

# QEMU path
export PATH="$PATH:/c/Users/student/portable-dev/qemu/"

# ⭐ Git's own binaries (just in case)
export PATH="$PATH:/usr/bin"

# ⭐ Go (if installed via Scoop)
if [ -d "$(winpath "$USERPROFILE/scoop/apps/go/current/bin")" ]; then
  export PATH="$PATH:$(winpath "$USERPROFILE/scoop/apps/go/current/bin")"
fi

# ⭐ Rust (Cargo)
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$PATH:$HOME/.cargo/bin"
fi

# ⭐ Python (uv/pipx)
# In Git Bash, uv + pipx still use Windows paths
if [ -d "$(winpath "$USERPROFILE/.local/bin")" ]; then
  export PATH="$PATH:$(winpath "$USERPROFILE/.local/bin")"
fi

# ⭐ Node (npm global tools)
if [ -d "$HOME/AppData/Roaming/npm" ]; then
  export PATH="$PATH:$(winpath "$HOME/AppData/Roaming/npm")"
fi

# Add ~/bin to PATH for custom scripts
export PATH="$PATH:$(winpath "$HOME/bin")"
###############################################
# TERMINAL + NEOVIM FIXES
###############################################

# Proper terminal type for neovim + fzf + lazyvim
export TERM=xterm-256color

# Fix display issues in nvim inside Git Bash
export COLORTERM=truecolor

# Set COLUMNS for proper ls formatting in Git Bash + WezTerm
export COLUMNS=80

# Make bash less noisy when running shells inside shells
export PROMPT_COMMAND=''

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
# zoxide (smart cd)
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

eval "$(starship init bash)"
eval "$(zoxide init bash)"
