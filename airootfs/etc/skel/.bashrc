#
# ~/.bashrc
#

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

#alias cp="cp -i"                          # confirm before overwriting something
#alias df='df -h'                          # human-readable sizes
#alias free='free -m'                      # show sizes in MB
#alias np='nano -w PKGBUILD'
#alias more=less

xhost +local:root > /dev/null 2>&1

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

alias fastfetch="fastfetch -l /usr/share/ascii/ascii_fast.txt --logo-color-1 '38;2;198;174;235'"







confirm_makepkg() {
    # List of makepkg options that shouldn't require a PKGBUILD
    local SAFE_ONLY_FLAGS=(--help -h --version -V --printsrcinfo)

    # If any safe flag is passed, bypass all checks
    for arg in "$@"; do
        for safe in "${SAFE_ONLY_FLAGS[@]}"; do
            if [[ "$arg" == "$safe" ]]; then
                command makepkg "$@"
                return $?
            fi
        done
    done

    # Check for --neverask
    if [[ -f "$HOME/.makepkg_neverask" ]]; then
        command makepkg "$@"
        return $?
    fi

    # Handle --neverask
    for arg in "$@"; do
        if [[ "$arg" == "--neverask" ]]; then
            touch "$HOME/.makepkg_neverask"
            set -- "${@/--neverask/}"
            command makepkg "$@"
            return $?
        fi
    done

    # Check if --noconfirm is passed
    for arg in "$@"; do
        if [[ "$arg" == "--noconfirm" ]]; then
            command makepkg "$@"
            return $?
        fi
    done

    local PKGFILE="./PKGBUILD"

    if [[ ! -f "$PKGFILE" ]]; then
        echo "No PKGBUILD found in current directory."
        return 1
    fi

    # Show PKGBUILD content
    cat "$PKGFILE"

    # Red colored warning using ANSI escape codes
    echo -e "
\033[1;31mATTENTION!
   
You are about to prepare a package out of the safe repository. 
Please read the PKGBUILD file provided above CAREFULLY before proceeding further! 
Otherwise you may get your operating system infected with malware or make it unstable.
Do you want to continue? (Y/N)\033[0m"

    # Prompt for user input
    read -r -n 1 answer
    echo  # move to new line

    if [[ "$answer" == [Yy] ]]; then
        command makepkg "$@"
    else
        echo "Aborted."
        return 0
    fi
}

# Create alias to use the function
alias makepkg='confirm_makepkg'







confirm_paru() {
    # Check for --neverask
    if [[ -f "$HOME/.makepkg_neverask" ]]; then
        command makepkg "$@"
        return $?
    fi

    # Handle --neverask
    for arg in "$@"; do
        if [[ "$arg" == "--neverask" ]]; then
            touch "$HOME/.makepkg_neverask"
            set -- "${@/--neverask/}"
            command makepkg "$@"
            return $?
        fi
    done

    # Check if --noconfirm is passed
    for arg in "$@"; do
        if [[ "$arg" == "--noconfirm" ]]; then
            command makepkg "$@"
            return $?
        fi
    done

    # Save user command arguments
    local args=("$@")

    # Red-colored warning message
    echo -e "
\033[1;31mATTENTION!

You are about to prepare a package out of the safe repository. 
Please read the PKGBUILD file provided by \"paru\" in next step CAREFULLY before proceeding further! 
Otherwise you may get your operating system infected with malware or make it unstable.

Do you want to continue? (Y/N)\033[0m"

    # Prompt user input
    read -r -n 1 answer
    echo  # new line for cleanliness

    if [[ "$answer" == [Yy] ]]; then
        # Proceed with the actual command using saved arguments
        command paru "${args[@]}"
    else
        echo "Aborted."
        return 0
    fi
}

# Alias paru to our function
alias paru='confirm_paru'
