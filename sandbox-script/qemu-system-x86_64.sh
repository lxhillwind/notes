#!/bin/bash
set -e

qemu="/bin/qemu-system-x86_64"

spice_socket_dir=/tmp/vm_spice/
mkdir -p "$spice_socket_dir"

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
    --setenv PATH "$HOME/bin":/usr/bin --setenv USER "$USER" --setenv HOME ~
    # app
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    # lib and bin
    --ro-bind /usr /usr --ro-bind /lib64 /lib64 --ro-bind /bin /bin

    # proc, sys, dev
    --proc /proc
    # --ro-bind /sys /sys; see https://wiki.archlinux.org/title/Bubblewrap
    --ro-bind /sys/dev/char /sys/dev/char
    --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    --dev /dev
    --dev-bind /dev/dri /dev/dri
    # required for kvm.
    --dev-bind /dev/kvm /dev/kvm

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

    # sound does not work, don't know why.

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    # app

    --tmpfs /tmp
    --bind "$spice_socket_dir" "$spice_socket_dir"
    --setenv TMPDIR "$spice_socket_dir"
    --tmpfs ~

    # we will call bwrap in remote-viewer, so mount related stuff.
    --ro-bind ~/.sandbox/archlinux/ ~/.sandbox/archlinux/

    --ro-bind ~/.config/mimeapps.list ~/.config/mimeapps.list
    --ro-bind ~/bin/remote-viewer ~/bin/remote-viewer
    --ro-bind ~/.local/share/applications/remote-viewer.desktop ~/.local/share/applications/remote-viewer.desktop
    --bind ~/qemu/ ~/qemu/
    --chdir ~/qemu/

    # this is to make xdg-open work (optional?)
    --setenv XDG_CURRENT_DESKTOP X-GENERIC

    # network.
    --unshare-all --share-net

    # security
    --die-with-parent --new-session
)

# -L option is workaround for `qemu: could not load PC BIOS 'bios-256k.bin'`.
# (in sandbox)
# see https://unix.stackexchange.com/questions/134893/cannot-start-kvm-vm-because-missing-bios
exec bwrap "${flags[@]}" -- "$qemu" -L /usr/share/qemu/ "$@"
