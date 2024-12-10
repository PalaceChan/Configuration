if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Env

PATH=$PATH:~/scripts
PATH=$PATH:~/.local/bin
export PATH

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec startx
fi
