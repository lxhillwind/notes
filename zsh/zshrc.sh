source ~/.config/env.sh

alias o=xdg-open

export MPD_HOST=~/.mpd/socket

mpc-fzf()
{
    mpc playlist | awk 'begin { i=0 } { print(++i, ")", $0) }' | fzf | awk '{ print $1 }' | xargs -r mpc play
}

# capture tmux output to put in vim (easy jump to file of rg / grep output)
# optional $1: start line from visible top; default: 1000
if [ -n "$TMUX" ]; then
sv()
{
    tmux capture -e -p -S -${1:-0} -E $(tmux display -p "#{cursor_y}") | vim - -c 'set buftype=nofile noswapfile | %Terminal cat'
}

# capture tmux output to fzf (for cd)
# optional $1: start line from visible top; default: 1
# TODO use vim's jump feature.
sc()
{
    result=$(tmux capture -p -S -${1:-1} -E $(tmux display -p "#{cursor_y}") | fzf)
    if [ -d "$result" ]; then
        cd "$result"
    else
        printf "\x1b[31mfile not reachable:\x1b[0m $result\n" >&2
    fi
}
fi

# x11 / wayland env {{{
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ]; then
    _common() {
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
        export XMODIFIERS=@im=fcitx
        [ -s ~/.mpd/pid ] || mpd
    }
    _start-wayland() {
        XDG_SESSION_TYPE=wayland dbus-run-session startplasma-wayland
    }
    _s() {
        _common
        export QT_QPA_PLATFORM=wayland
        export SDL_VIDEODRIVER=wayland
        _start-wayland
    }

    x() {
        # plasma has its own value.
        export QT_QPA_PLATFORMTHEME=qt5ct
        _common
        startx
    }

    s() {
        (_s)
    }
fi
# }}}

alias pq='proxychains -q'
# vim:fdm=marker
