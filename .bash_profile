function ff()
{
	find -type f -iname "*${1}*"
}

function cg()
{
    find . \( -iname "*.[CcHh]" -o -iname "*.cpp" -o -iname "*.hpp" \) | parallel -j150% -n 1000 "grep -nHi "$1" {}"
}

function mg()
{
    find . \( -iname "*.mk" -o -iname "*makefile*" \) -exec grep -nHi "$1" {} \;
}

function xmlg()
{
    find . \( -iname "*.xml" \) | parallel -j150% -n 1000 "grep -nHi "$1" {}"
}

function mgrep()
{
    CMD=''
    while (($#)); do
        CMD="$CMD grep '$1' | ";
        shift;
    done;
    eval ${CMD%| }
}

function ediff
{
    if [ -d $1 ]; then
	emacsclient -q -eval "(ztree-diff \"$1\" \"$2\")"
    else
	emacsclient -q -eval "(ediff-files \"$1\" \"$2\")"
    fi
}

################################################################################

alias e='/usr/bin/emacsclient -n'
alias ew='/usr/bin/emacs -nw'
alias em='/usr/bin/emacs'
alias hist='cat ~/history/history.txt'
alias ls='ls --color=auto -h'
alias reset='echo -e \\033c'
alias rc='source ~/.bash_profile'

if [ "eterm-color" == "$TERM" ]; then
    alias less='cat'
    alias more='cat'
    export PAGER=cat
    export EDITOR=emacsclient
else
    export EDITOR='emacs -nw'
fi

################################################################################

export LESS='-iMFXR' #cat if fits

export HISTSIZE=
export HISTFILESIZE=
export HISTTIMEFORMAT='%Y%m%d %T '
export HISTFILE=~/.bash_eternal_history

PROMPT_COMMAND='history -a; history | tail -n1 | ~/history/dump_history.sh'
export PROMPT_COMMAND

PATH=$PATH:~/scripts
export PATH

export PS1='\h: '
xset r rate 200 70

################################################################################

function vterm_printf()
{
    if [ -n "$TMUX" ]; then
        # Tell tmux to pass the escape sequences through
        # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

function vterm_prompt_end()
{
    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
}

PS1=$PS1'\[$(vterm_prompt_end)\]'

