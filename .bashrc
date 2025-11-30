###############################################
# WINDOWS DEV PATHS FOR GIT BASH (MINGW64)
###############################################

# Convert Windows-style paths to Unix paths automatically
winpath() {
  /usr/bin/cygpath -u "$1"
}

# ⭐ Scoop shims (wezterm, nvim, rg, bat, etc.)
export PATH="$PATH:$(winpath "$USERPROFILE/scoop/shims")"

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

###############################################
# TERMINAL + NEOVIM FIXES
###############################################

# Proper terminal type for neovim + fzf + lazyvim
export TERM=xterm-256color

# Fix display issues in nvim inside Git Bash
export COLORTERM=truecolor

# Make bash less noisy when running shells inside shells
export PROMPT_COMMAND=''

###############################################
# OPTIONAL QUALITY OF LIFE
###############################################

# Colorize ls, grep, etc.
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Make vim = nvim
command -v nvim >/dev/null && alias vim='nvim'
