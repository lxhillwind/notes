#!/bin/bash
set -e

# bwrap (bubblewrap) is required.

qutebrowser="/usr/bin/qutebrowser"

if ! command -v bwrap >/dev/null; then
    exec "$qutebrowser"
fi

mkdir -p "$XDG_RUNTIME_DIR"/qutebrowser-box/

if [ -n "$WAYLAND_DISPLAY" ]; then
    flags_gui=(
        # wayland (qt)
        --setenv QT_QPA_PLATFORM wayland
        --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
        --ro-bind /run/user/"$UID"/"$WAYLAND_DISPLAY" /run/user/"$UID"/"$WAYLAND_DISPLAY"
        # qt5 theme
        --setenv QT_QPA_PLATFORMTHEME qt5ct
        --ro-bind ~/.config/qt5ct/ ~/.config/qt5ct/
        # wayland text editor (gvim) wrapper; since gvim gtk3 does not work in wayland...
        --ro-bind ~/bin/gvim ~/bin/gvim
        --setenv PATH "$HOME"/bin:/usr/bin
    )
else
    flags_gui=(
        # x11
        --setenv DISPLAY "$DISPLAY"
        --ro-bind ~/.Xauthority ~/.Xauthority
    )
fi

flags=(
    # env:
    --clearenv
    # basic
    --setenv PATH /usr/bin --setenv USER "$USER" --setenv HOME ~
    # fcitx
    --setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS"
    --setenv QT_IM_MODULE "$QT_IM_MODULE" --setenv GTK_IM_MODULE "$GTK_IM_MODULE" --setenv XMODIFIERS "$XMODIFIERS"
    # app
    --setenv SANDBOXED_QUTEBROWSER 1
    # app
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    # lib and bin
    --ro-bind /usr /usr --ro-bind /lib64 /lib64 --ro-bind /bin /bin
    --tmpfs /tmp

    # proc, sys, dev
    --proc /proc
    # --ro-bind /sys /sys; see https://wiki.archlinux.org/title/Bubblewrap
    --ro-bind /sys/dev/char /sys/dev/char
    --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    --dev /dev
    # for webgl
    --dev-bind /dev/dri/ /dev/dri/

    # font and network (also --share-net)
    --ro-bind /etc/fonts/ /etc/fonts/ --ro-bind /etc/resolv.conf /etc/resolv.conf
    # fcitx
    --ro-bind /run/user/"$UID"/bus /run/user/"$UID"/bus

    "${flags_gui[@]}"

    # sound (pipewire)
    --ro-bind /run/user/"$UID"/pipewire-0 /run/user/"$UID"/pipewire-0
    # sound (pulseaudio); use it even if using pipewire-pulse.
    --ro-bind /run/user/"$UID"/pulse /run/user/"$UID"/pulse

    # it throws warning. so add it.
    --ro-bind /run/dbus/system_bus_socket /run/dbus/system_bus_socket

    # app
    --bind "$XDG_RUNTIME_DIR"/qutebrowser-box/ "$XDG_RUNTIME_DIR"/qutebrowser/
    # bind ~/.config/qutebrowser as rw is required, otherwise quickmark will fail.
    --bind ~/.config/qutebrowser/ ~/.config/qutebrowser/
    --ro-bind ~/.config/qutebrowser/config.py ~/.config/qutebrowser/config.py
    --ro-bind ~/.config/qutebrowser/userscripts/ ~/.config/qutebrowser/userscripts/
    # if rc.py is available, then mount it.
    --ro-bind ~/.config/qutebrowser/rc.py ~/.config/qutebrowser/rc.py
    # use separate history.
    --bind ~/.local/share/qutebrowser-box/ ~/.local/share/qutebrowser/
    # app
    --bind ~/Downloads/ ~/Downloads/
    # app
    --ro-bind ~/html/ ~/html/
    --ro-bind ~/.vimrc ~/.vimrc --ro-bind ~/vimfiles/ ~/vimfiles/

    # network.
    --unshare-all --share-net
)

exec bwrap "${flags[@]}" -- "$qutebrowser" "$@"
