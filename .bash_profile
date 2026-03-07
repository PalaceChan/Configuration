if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Env

case ":$PATH:" in
    *":$HOME/scripts:"*) ;;
    *) PATH="$PATH:$HOME/scripts" ;;
esac
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$PATH:$HOME/.local/bin" ;;
esac
export PATH

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && command -v startx >/dev/null 2>&1; then
    exec startx
fi
