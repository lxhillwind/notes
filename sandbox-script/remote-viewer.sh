#!/bin/bash
set -e

remote_viewer="/bin/remote-viewer"

spice_socket_dir=/tmp/vm_spice/

# bwrap (bubblewrap) is required.

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
    --ro-bind /sys/dev/char /sys/dev/char
    --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    --dev /dev
    --dev-bind /dev/dri /dev/dri

    # font and network (also --share-net)
    --ro-bind /etc/fonts/ /etc/fonts/ --ro-bind /etc/resolv.conf /etc/resolv.conf
    # icon
    --setenv QT_AUTO_SCREEN_SCALE_FACTOR "$QT_AUTO_SCREEN_SCALE_FACTOR"
    --setenv QT_WAYLAND_FORCE_DPI "$QT_WAYLAND_FORCE_DPI"
    --setenv PLASMA_USE_QT_SCALING "$PLASMA_USE_QT_SCALING"
    --setenv XCURSOR_SIZE "$XCURSOR_SIZE"
    --setenv XCURSOR_THEME "$XCURSOR_THEME"
    --ro-bind /usr/share/icons/ /usr/share/icons/

    "${flags_gui[@]}"

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    # app
    --tmpfs /tmp
    --bind "$spice_socket_dir" "$spice_socket_dir"
    # fontconfig write to ~. "Fontconfig error: No writable cache directories"
    --tmpfs ~

    # network.
    --unshare-all --share-net
)

exec bwrap "${flags[@]}" -- "$remote_viewer" "$@"
