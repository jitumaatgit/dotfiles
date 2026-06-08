bleopt input_encoding=UTF-8

# settings for vim mode
function blerc/vim-mode-hook {
  bleopt keymap_vi_mode_string_nmap=$'\e[1m-- NORMAL --\e[m'
}
blehook/eval-after-load keymap_vi blerc/vim-mode-hook

# Bind "C-x C-v" for Vim mode
VISUAL='vim -X'
ble-bind -m vi_imap -f 'C-x C-v' 'edit-and-execute-command'
ble-bind -m vi_nmap -f 'C-x C-v' 'vi-command/edit-and-execute-command'

# bind `g g` `G` to move to first/last-line
ble-bind -m vi_nmap -f 'g g' vi-command/first-nol
ble-bind -m vi_omap -f 'g g' vi-command/first-nol
ble-bind -m vi_xmap -f 'g g' vi-command/first-nol
ble-bind -m vi_nmap -f 'G' vi-command/last-line
ble-bind -m vi_omap -f 'G' vi-command/last-line
ble-bind -m vi_xmap -f 'G' vi-command/last-line

# bind 'j k / k j' to moving from insert to normal mode with resonable waiting period
ble-bind -m vi_imap -f 'k j' vi_imap/normal-mode
ble-bind -m vi_imap -f 'j k' vi_imap/normal-mode
ble-bind -m vi_imap -T j 60 # If no k within 40ms, treat it as a normal j input
ble-bind -m vi_imap -T k 60 # Same idea

# turn off case sensitive auto-completion
bind 'set completion-ignore-case on'

# turn off exit status mark
bleopt exec_errexit_mark=

# restore PIPESTATUS
#bleopt exec_restore_pipestatus=1

################################
#        Performance           #
################################

# timeouts and limits for highlighting
bleopt highlight_timeout_async=5000
bleopt highlight_timeout_sync=50
bleopt highlight_eval_word_limit=200

# turn off highlighting of completion candidates

# Note: This internally sets "bind 'set colored-stats off'".
bleopt complete_menu_color=off

# Note: This internally sets "bind 'set colored-completion-prefix off'".
bleopt complete_menu_color_match=on

# reduce time and frequecy of completion generation
bleopt complete_limit_auto=2000
bleopt complete_limit_auto_menu=100
bleopt complete_timeout_auto=5000
bleopt complete_timeout_compvar=200
bleopt complete_polling_cycle=50

# add delay in starting the processing of auto-completion
bleopt complete_auto_delay=500
bleopt complete_auto_menu=500

# reduce time of constructing menu:

# Limit the menu height
bleopt complete_menu_maxlines=10

# Use a simple layout for the menu
bleopt complete_menu_style=dense
