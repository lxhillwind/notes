#!/bin/bash
set -e

mpDris2="/usr/local/bin/mpDris2"

# bwrap (bubblewrap) is required.

mpDris2_cover_dir=/tmp/mpDris2-cover/

mkdir -p "$mpDris2_cover_dir"

if [ -n "$WAYLAND_DISPLAY" ]; then
    # wayland
    flags_gui=(
        --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
        --ro-bind /run/user/"$UID"/"$WAYLAND_DISPLAY" /run/user/"$UID"/"$WAYLAND_DISPLAY"
    )
else
    # x11
    flags_gui=(
        --setenv DISPLAY "$DISPLAY"
        --ro-bind ~/.Xauthority ~/.Xauthority
    )
fi

flags=(
    # env:
    --clearenv
    # basic
    --setenv PATH /usr/bin --setenv USER "$USER" --setenv HOME ~
    # app
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    # lib and bin
    #--ro-bind /usr /usr --ro-bind /lib64 /lib64 --ro-bind /bin /bin
    --ro-bind ~/.sandbox/archlinux/usr /usr
    --ro-bind ~/.sandbox/archlinux/lib64 /lib64
    --ro-bind ~/.sandbox/archlinux/bin /bin
    --tmpfs /tmp

    # proc, sys, dev
    --proc /proc
    # --ro-bind /sys /sys; see https://wiki.archlinux.org/title/Bubblewrap
    #--ro-bind /sys/dev/char /sys/dev/char
    #--ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    #--dev /dev

    # font and network (also --share-net)
    #--ro-bind /etc/fonts/ /etc/fonts/ --ro-bind /etc/resolv.conf /etc/resolv.conf
    # icon
    #--setenv QT_AUTO_SCREEN_SCALE_FACTOR "$QT_AUTO_SCREEN_SCALE_FACTOR"
    #--setenv QT_WAYLAND_FORCE_DPI "$QT_WAYLAND_FORCE_DPI"
    #--setenv PLASMA_USE_QT_SCALING "$PLASMA_USE_QT_SCALING"
    #--setenv XCURSOR_SIZE "$XCURSOR_SIZE"
    #--setenv XCURSOR_THEME "$XCURSOR_THEME"
    #--ro-bind /usr/share/icons/ /usr/share/icons/

    #"${flags_gui[@]}"

    # sound (pipewire)
    #--ro-bind /run/user/"$UID"/pipewire-0 /run/user/"$UID"/pipewire-0
    # sound (pulseaudio); use it even if using pipewire-pulse.
    #--ro-bind /run/user/"$UID"/pulse /run/user/"$UID"/pulse

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    # app
    --setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS"
    --bind ~/.mpd/ ~/.mpd/
    --ro-bind ~/music/ ~/music/
    --ro-bind ~/.config/mpd/ ~/.config/mpd/
    --bind "$mpDris2_cover_dir" "$mpDris2_cover_dir"
    # this is set in config.
    --setenv MPD_HOST ~/.mpd/socket

    # network.
    # NOTE: --share-net is required!
    --unshare-all --share-net

    # security
    --die-with-parent --new-session
)

exec bwrap "${flags[@]}" -- "$mpDris2" "$@"
