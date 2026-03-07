# Functions
function ff()
{
    local dir="${2:-.}"
	find "$dir" -type f -iname "*${1}*" 2>/dev/null
}

function mgrep()
{
    local awk_script='1'
    local awk_args=()
    local i=0

    while (($#)); do
        i=$((i + 1))
        awk_script="$awk_script && \$0 ~ pat$i"
        awk_args+=(-v "pat$i=$1")
        shift
    done

    awk "${awk_args[@]}" "$awk_script"
}

function ediff
{
    local left=$1
    local right=$2
    local left_elisp
    local right_elisp

    if [ -z "$left" ] || [ -z "$right" ]; then
        echo "usage: ediff PATH1 PATH2" >&2
        return 1
    fi

    left_elisp=${left//\\/\\\\}
    left_elisp=${left_elisp//\"/\\\"}
    right_elisp=${right//\\/\\\\}
    right_elisp=${right_elisp//\"/\\\"}

    if [ -d "$left" ]; then
	emacsclient -q --eval "(ztree-diff \"$left_elisp\" \"$right_elisp\")"
    else
	emacsclient -q --eval "(ediff-files \"$left_elisp\" \"$right_elisp\")"
    fi
}

function vterm_printf() {
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ]); then
        # Tell tmux to pass the escape sequences through
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

# Aliases
alias e='/usr/bin/emacsclient -n'
alias ew='/usr/bin/emacs -Q -nw'
alias hist='cat ~/history/history.txt'
alias ls='ls --color=auto -h'
alias reset='echo -e \\033c'
alias R='R --no-save --no-restore-data --quiet'

if [ "eterm-color" == "$TERM" ]; then
    alias less='cat'
    alias more='cat'
    export PAGER=cat
    export EDITOR=emacsclient
else
    export EDITOR='emacs -nw'    
fi

# Env
export PS1='\h: \[$(vterm_prompt_end)\]'
export LESS='-iMFXR' #cat if fits
export R_HISTFILE="$HOME/.Rhistory"

# Intentionally unlimited history; everything is persisted to HISTFILE.
export HISTSIZE=
export HISTFILESIZE=
export HISTTIMEFORMAT='%Y%m%d %T '
export HISTFILE=~/.bash_eternal_history
export PROMPT_COMMAND='history -a; history 1 | ~/history/dump_history.sh'
