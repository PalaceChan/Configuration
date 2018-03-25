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

alias e='/usr/bin/emacs25 -nw'
alias em='/usr/bin/emacs25'
alias hist='cat ~/history/history.txt'
alias ls='ls --color=auto -h'
alias reset='echo -e \\033c'
alias rc='source ~/.bash_profile'

################################################################################

export LESS='-iMFXR' #cat if fits

EDITOR='emacs -nw'
export EDITOR

PROMPT_COMMAND='history | tail -n1 | ~/history/dump_history.sh'
export PROMPT_COMMAND

PATH=$PATH:~/rabbit
export PATH

export PS1='\h: '

#export R_LIBS_USER=/home/andres/R
export R_LIBS_USER=/home/andres/R-3.4.4
