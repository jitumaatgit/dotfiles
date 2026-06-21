export USER=$USERNAME

[[ $- == *i* ]] && source -- ~/scripts/blesh/ble.sh --attach=none

# ble.sh reminders (no vim mode — emacs mode)
echo "  C-x C-e  → edit current command in $EDITOR"
echo "  C-r      → search history"

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

export CARGO_HOME="$HOME/scoop/persist/rustup/.cargo"
export RUSTUP_HOME="$HOME/scoop/persist/rustup/.rustup"

if [ -d "$CARGO_HOME/bin" ]; then
  export PATH="$PATH:$CARGO_HOME/bin"
fi

if [ -d "$win_up/.local/bin" ]; then
  export PATH="$PATH:$win_up/.local/bin"
fi

if [ -d "$HOME/AppData/Roaming/npm" ]; then
  export PATH="$PATH:$HOME/AppData/Roaming/npm"
fi

export PATH="$PATH:$HOME/bin"

###############################################
# ANDROID DEV (Bandito)
###############################################
export JAVA_HOME="$HOME/scoop/apps/temurin-lts-jdk/current"
export ANDROID_HOME="$HOME/scoop/apps/android-clt/current"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$HOME/scoop/apps/gradle/current/bin:$PATH"

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
# Aliases — bash-doc pattern (see /usr/share/doc/bash/examples/startup-files/Bash_aliases)
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# zoxide (smart cd) — lazy-loaded on first use
z() {
  unset -f z
  eval "$(zoxide init bash)"
  z "$@"
}
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

# starship — lazy-loaded via ble.sh precmd hook, fallback if ble.sh missing
if [[ ${BLE_VERSION-} ]]; then
  __starship_lazy() {
    blehook PRECMD-='__starship_lazy'
    eval "$(starship init bash)"
  }
  blehook PRECMD+='__starship_lazy'
else
  eval "$(starship init bash)"
fi
[[ ! ${BLE_VERSION-} ]] || ble-attach
