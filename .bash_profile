if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Env

PATH=$PATH:~/scripts
PATH=$PATH:~/.local/bin
export PATH

xset r rate 200 70
