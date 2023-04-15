#!/bin/bash
set -e

# why using mpv in sandbox?
# - does not leave footprint.

mpv="/usr/bin/mpv"

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
    # check lib path via `file {binary}`.
    --ro-bind /usr /usr
    --ro-bind /bin /bin
    --ro-bind /lib64 /lib64
    --ro-bind /etc/fonts /etc/fonts

    # fix missing lib
    --ro-bind /etc/ld.so.conf /etc/ld.so.conf
    --ro-bind /etc/ld.so.conf.d /etc/ld.so.conf.d
    --ro-bind /etc/ld.so.cache /etc/ld.so.cache
    --ro-bind /etc/alternatives /etc/alternatives

    --tmpfs /tmp

    # proc, sys, dev
    --proc /proc
    # --ro-bind /sys /sys; see https://wiki.archlinux.org/title/Bubblewrap
    --ro-bind /sys/dev/char /sys/dev/char
    --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    --dev /dev
    # for gl?
    --dev-bind /dev/dri/ /dev/dri/

    # network (also --share-net)
    --ro-bind /etc/resolv.conf /etc/resolv.conf

    # icon
    --setenv XCURSOR_SIZE "$XCURSOR_SIZE"
    --setenv XCURSOR_THEME "$XCURSOR_THEME"

    "${flags_gui[@]}"

    # sound (pipewire)
    --ro-bind /run/user/"$UID"/pipewire-0 /run/user/"$UID"/pipewire-0
    # sound (pulseaudio); use it even if using pipewire-pulse.
    --ro-bind /run/user/"$UID"/pulse /run/user/"$UID"/pulse

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    --ro-bind ~/.config/mpv/ ~/.config/mpv/

    # network.
    --unshare-all --share-net

    # security
    --new-session
    # allow to run it in background... (from cli)
    #--die-with-parent
)

# TODO multi file
for arg in "$@"; do
    if [ -e "$arg" ]; then
        shopt -s nullglob
        abs=1
        if [[ $arg =~ ^/.* ]]; then
            flags=("${flags[@]}" --ro-bind "$arg" "$arg")
        else
            abs=
            flags=("${flags[@]}" --ro-bind "$arg" "$PWD/$arg" --chdir "$PWD")
        fi

        filename_prefix="${arg%.*}"
        for file in "$filename_prefix".ass "$filename_prefix".*.ass; do
            if [ -e "$file" ]; then
                if [[ -n "$abs" ]]; then
                    flags=("${flags[@]}" --ro-bind "$file" "$file")
                else
                    flags=("${flags[@]}" --ro-bind "$file" "$PWD"/"$file")
                fi
            fi
        done
    fi
done

exec bwrap "${flags[@]}" -- "$mpv" "$@"
