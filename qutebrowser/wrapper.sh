#!/bin/bash
set -e

# bwrap (bubblewrap) is required.

qutebrowser="/usr/bin/qutebrowser"

if ! command -v bwrap >/dev/null; then
    exec "$qutebrowser"
fi

mkdir -p "$XDG_RUNTIME_DIR"/qutebrowser/

flags=(
    # env:
    --clearenv
    # used in application
    --setenv SANDBOXED_QUTEBROWSER 1
    # basic
    --setenv PATH /usr/bin --setenv USER "$USER" --setenv HOME ~
    # app
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    # x11
    --setenv DISPLAY "$DISPLAY"
    # fcitx
    --setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS"
    --setenv QT_IM_MODULE "$QT_IM_MODULE" --setenv GTK_IM_MODULE "$GTK_IM_MODULE" --setenv XMODIFIERS "$XMODIFIERS"
    # lib and bin
    --ro-bind /usr /usr --ro-bind /lib64 /lib64 --ro-bind /bin /bin
    --ro-bind /dev/null /bin/su --ro-bind /dev/null /bin/sudo
    --ro-bind /dev/null /usr/bin/su --ro-bind /dev/null /usr/bin/sudo
    # proc, sys, dev
    --proc /proc
    --dev-bind /dev /dev
    --bind /sys /sys
    # rw required for qt lib.
    --bind /dev/shm /dev/shm
    # app
    --bind "$XDG_RUNTIME_DIR"/qutebrowser/ "$XDG_RUNTIME_DIR"/qutebrowser/
    # font and network
    --ro-bind /etc/fonts/ /etc/fonts/ --ro-bind /etc/resolv.conf /etc/resolv.conf
    # it throws warning. so add it.
    --ro-bind /run/dbus/system_bus_socket /run/dbus/system_bus_socket
    # fcitx and network
    --ro-bind /run/user/"$UID"/bus /run/user/"$UID"/bus --ro-bind /run/systemd/resolve/ /run/systemd/resolve/
    # x11
    --ro-bind ~/.Xauthority ~/.Xauthority
    # sound requires additional setting.
    # see https://wiki.archlinux.org/title/PulseAudio/Examples#Allowing_multiple_users_to_share_a_PulseAudio_daemon
    --ro-bind ~/.config/pulse/client.conf ~/.config/pulse/client.conf
    --ro-bind /tmp/pulse-socket /tmp/pulse-socket
    # bind ~/.config/qutebrowser as rw is required, otherwise quickmark will fail.
    --bind ~/.config/qutebrowser/ ~/.config/qutebrowser/
    --ro-bind ~/.config/qutebrowser/config.py ~/.config/qutebrowser/config.py
    --ro-bind ~/.config/qutebrowser/userscripts/ ~/.config/qutebrowser/userscripts/
    # if rc.py is available, then mount it.
    --ro-bind ~/.config/qutebrowser/rc.py ~/.config/qutebrowser/rc.py
    # use separate history.
    --bind ~/.local/share/qutebrowser-box/ ~/.local/share/qutebrowser/

    # common share
    --bind ~/Downloads/ ~/Downloads/

    # app
    --ro-bind ~/html/ ~/html/
    --ro-bind ~/.vimrc ~/.vimrc --ro-bind ~/vimfiles/ ~/vimfiles/
)

exec bwrap "${flags[@]}" -- "$qutebrowser" "$@"
