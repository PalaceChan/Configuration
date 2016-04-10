function ff()
{
	find -type f -iname "*${1}*"
}

function cpp()
{
	g++ -x c++ -o a.out - && echo && echo "------------------------------------Output------------------------------------" && ./a.out && rm a.out
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

alias hist='cat /home/andres/history/history.txt'

################################################################################

EDITOR='emacs -nw'
export EDITOR

PROMPT_COMMAND='history | tail -n1 | /home/andres/history/dump_history.sh'
export PROMPT_COMMAND

#rawdog android
#PATH=$PATH:/home/andres/android-sdk-linux/tools
#export PATH

PATH=$PATH:/home/andres/rabbit
export PATH

source ~/.bash_aliases
