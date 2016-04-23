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

function rg()
{
    find . \( -iname "*.R" \) | parallel -j150% -n 1000 "grep -nHi "$1" {}"
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

################################################################################

alias e='emacs -nw'
alias hist='cat /home/andres/history/history.txt'
alias ls='ls --color=auto -h'
alias reset='echo -e \\033c'

################################################################################

export LESS='-iMFXR' #cat if fits

EDITOR='emacs -nw'
export EDITOR

PROMPT_COMMAND='history | tail -n1 | /home/andres/history/dump_history.sh'
export PROMPT_COMMAND

PATH=$PATH:/home/andres/rabbit
export PATH

export PS1='\h: '
