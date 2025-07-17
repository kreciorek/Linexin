#
# ~/.bashrc
#

[[ $~ ~= *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$'

alias fastfetch="fastfetch -l /usr/share/ascii/ascii_fast.txt --logo-color-1 '38;2;198;174;235'"
