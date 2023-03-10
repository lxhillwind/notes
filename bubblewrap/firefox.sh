#!/bin/bash
set -e

# bwrap (bubblewrap) is required.

firefox="/usr/bin/firefox"

if ! command -v bwrap >/dev/null; then
    exec "$firefox"
fi

mkdir -p ~/.mozilla-box
mkdir -p ~/.local/share/tridactyl-box
mkdir -p ~/.config/transmission-box

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
        # fcitx
        --ro-bind /run/user/"$UID"/bus /run/user/"$UID"/bus
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
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    # lib and bin
    # check lib path via `file {binary}`.
    --ro-bind ~/.sandbox/archlinux/usr /usr
    --ro-bind ~/.sandbox/archlinux/bin /bin
    --ro-bind ~/.sandbox/archlinux/lib64 /lib64
    --ro-bind /usr/share/fonts /usr/share/fonts
    --ro-bind /etc/fonts /etc/fonts
    --tmpfs /tmp

    # proc, sys, dev
    --proc /proc
    # --ro-bind /sys /sys; see https://wiki.archlinux.org/title/Bubblewrap
    --ro-bind /sys/dev/char /sys/dev/char
    --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    --ro-bind /sys/bus/pci /sys/bus/pci
    --dev /dev
    # for webgl
    --dev-bind /dev/dri/ /dev/dri/

    # timezone
    --ro-bind /etc/localtime /etc/localtime
    # network (also --share-net)
    --ro-bind /etc/resolv.conf /etc/resolv.conf
    # icon
    --setenv QT_AUTO_SCREEN_SCALE_FACTOR "$QT_AUTO_SCREEN_SCALE_FACTOR"
    --setenv XCURSOR_SIZE "$XCURSOR_SIZE"
    --setenv XCURSOR_THEME "$XCURSOR_THEME"
    --ro-bind /usr/share/icons/ /usr/share/icons/

    --dir /run/user/"$UID"/
    # TODO NOTE ok, this is dangerous. but if not, we cannot open url with existing instance.
    --ro-bind /run/user/"$UID"/bus /run/user/"$UID"/bus
    # sound (pipewire)
    --ro-bind /run/user/"$UID"/pipewire-0 /run/user/"$UID"/pipewire-0
    # sound (pulseaudio); use it even if using pipewire-pulse.
    --ro-bind /run/user/"$UID"/pulse /run/user/"$UID"/pulse

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    "${flags_gui[@]}"
    --ro-bind ~/.sandbox/archlinux/etc/ssl /etc/ssl
    --ro-bind ~/.sandbox/archlinux/etc/ca-certificates /etc/ca-certificates

    # font CJK fix
    --ro-bind ~/lx/linux/font-cjk-fix.conf ~/.config/fontconfig/fonts.conf
    # app
    --bind ~/.mozilla-box ~/.mozilla
    --bind ~/.local/share/tridactyl-box ~/.local/share/tridactyl
    --bind ~/.config/transmission-box ~/.config/transmission
    --setenv MOZ_ENABLE_WAYLAND 1

    --ro-bind ~/.config/tridactyl/ ~/.config/tridactyl/
    --bind ~/Downloads/ ~/Downloads/
    --ro-bind ~/html/ ~/html/
    --symlink ~/vimfiles/vimrc ~/.vimrc --ro-bind ~/vimfiles/ ~/vimfiles/
    # opensuse system doc.
    --ro-bind-try /usr/share/doc/packages/ ~/opensuse-doc-packages/

    # network.
    --unshare-all --share-net

    # security
    --new-session
    # disable --die-with-parent to allow `:restart` in it.
    #--die-with-parent
)

exec bwrap "${flags[@]}" -- "$firefox" "$@"
