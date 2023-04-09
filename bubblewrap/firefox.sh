#!/bin/bash
set -e

# prefer flags_fedora (fedora host) since it enables va-api by default;
#   (but why does not it take less cpu?)
# use flags_archlinux (archlinux sandbox) otherwise for its update frequency.

firefox="/usr/bin/firefox"

mkdir -p ~/.mozilla-box
mkdir -p ~/.local/share/tridactyl-box
mkdir -p ~/.config/transmission-box

flags_archlinux=(
    --ro-bind ~/.sandbox/archlinux/usr /usr
    --ro-bind ~/.sandbox/archlinux/bin /bin
    --ro-bind ~/.sandbox/archlinux/lib64 /lib64
    --ro-bind ~/.sandbox/archlinux/etc/ssl /etc/ssl
    --ro-bind ~/.sandbox/archlinux/etc/ca-certificates /etc/ca-certificates
    --ro-bind /etc/locale.conf /etc/locale.conf
    --ro-bind /usr/share/locale/ /usr/share/locale/
    --ro-bind /usr/share/fonts/ /usr/share/fonts/
    --ro-bind /etc/fonts /etc/fonts
    # timezone
    --ro-bind /etc/localtime /etc/localtime
    # network (also --share-net)
    --ro-bind /etc/resolv.conf /etc/resolv.conf
    # icon
    --setenv XCURSOR_SIZE "$XCURSOR_SIZE"
    --setenv XCURSOR_THEME "$XCURSOR_THEME"
    --ro-bind /usr/share/icons/ /usr/share/icons/
    )

flags_fedora=(
    --ro-bind /usr/ /usr/
    # mount /bin to make /bin/sh (/bin/bash, etc) work.
    --ro-bind /bin/ /bin/
    --ro-bind /lib64/ /lib64/
    # this is necessary to make network (ff in fedora) work.
    --ro-bind /etc/alternatives/ /etc/alternatives/
    # /etc/resolv.conf is symlink.
    --ro-bind /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    --ro-bind /etc/fonts/ /etc/fonts/
    )

if [ -n "$WAYLAND_DISPLAY" ]; then
    # wayland
    flags_gui=(
        --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
        --setenv MOZ_ENABLE_WAYLAND 1
        --ro-bind /run/user/"$UID"/"$WAYLAND_DISPLAY" /run/user/"$UID"/"$WAYLAND_DISPLAY"
    )
else
    # x11
    flags_gui=(
        --setenv DISPLAY "$DISPLAY"
        --ro-bind ~/.Xauthority ~/.Xauthority
    )
    dbus_file=$(printf %s "$DBUS_SESSION_BUS_ADDRESS" | sed 's/unix:path=//; s/,.*//')
    # fcitx;
    # NOTE: startup notification should be false (in firefox.desktop).
    if [ -S "$dbus_file" ]; then
        flags_gui=(
            "${flags_gui[@]}"
            # this seems to be /run/user/"$UID"/bus when started with lightdm;
            # /tmp/some-random-path when stared via startx.
            --ro-bind "$dbus_file" "$dbus_file"
        )
    fi
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
    --setenv LANG zh_CN.utf8
    --setenv LC_ALL zh_CN.utf8
    --setenv LC_CTYPE zh_CN.utf8

    #"${flags_archlinux[@]}"
    "${flags_fedora[@]}"

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

    # font CJK fix
    --ro-bind ~/lx/linux/font-cjk-fix.conf ~/.config/fontconfig/fonts.conf
    # app
    --bind ~/.mozilla-box ~/.mozilla
    --bind ~/.local/share/tridactyl-box ~/.local/share/tridactyl
    --bind ~/.config/transmission-box ~/.config/transmission

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
