bleopt input_encoding=UTF-8

# turn off case sensitive auto-completion
bind 'set completion-ignore-case on'

# minimal failure mark
bleopt exec_errexit_mark=$'x'

# restore PIPESTATUS
bleopt exec_restore_pipestatus=1

################################
#        Performance           #
################################

# disable syntax highlighting
bleopt highlight_syntax=

# disable auto-suggestions
bleopt complete_auto_complete=0
bleopt complete_auto_history=0

# reduce time and frequency of completion generation
bleopt complete_limit_auto=500
bleopt complete_timeout_auto=5000
bleopt complete_timeout_compvar=200
bleopt complete_polling_cycle=50

# add delay in starting the processing of auto-completion
bleopt complete_auto_delay=800
bleopt complete_auto_menu=600

# disable history sharing
bleopt history_share=0

# disable elapsed time mark
bleopt exec_elapsed_mark=

# turn off highlighting of completion candidates
# Note: This internally sets "bind 'set colored-stats off'".
bleopt complete_menu_color=off

# Note: This internally sets "bind 'set colored-completion-prefix off'".
bleopt complete_menu_color_match=on

# limit the menu height
bleopt complete_menu_maxlines=10

# use a simple layout for the menu
bleopt complete_menu_style=dense
