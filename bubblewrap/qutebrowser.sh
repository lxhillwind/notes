#!/bin/bash
set -e

# bwrap (bubblewrap) is required.

qutebrowser="/usr/bin/qutebrowser"

if ! command -v bwrap >/dev/null; then
    exec "$qutebrowser"
fi

mkdir -p "$XDG_RUNTIME_DIR"/qutebrowser-box/

if [ -n "$WAYLAND_DISPLAY" ]; then
    # wayland (qt)
    flags_gui=(
        --setenv QT_QPA_PLATFORM wayland
        --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
        --ro-bind /run/user/"$UID"/"$WAYLAND_DISPLAY" /run/user/"$UID"/"$WAYLAND_DISPLAY"
        # qt5 theme
        --setenv QT_QPA_PLATFORMTHEME qt5ct
        --ro-bind ~/.config/qt5ct/ ~/.config/qt5ct/
        ## wayland text editor (gvim) wrapper; since gvim gtk3 does not work in wayland...
        #--ro-bind ~/bin/gvim ~/bin/gvim
        #--ro-bind ~/bin/pbcopy ~/bin/pbcopy --ro-bind ~/bin/pbpaste ~/bin/pbpaste
        #--setenv PATH "$HOME"/bin:/usr/bin:/bin
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
    --setenv SANDBOXED_QUTEBROWSER 1
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
    --dev /dev
    # for webgl
    --dev-bind /dev/dri/ /dev/dri/

    # timezone
    --ro-bind /etc/localtime /etc/localtime
    # network (also --share-net)
    --ro-bind /etc/resolv.conf /etc/resolv.conf
    # icon
    --setenv QT_AUTO_SCREEN_SCALE_FACTOR "$QT_AUTO_SCREEN_SCALE_FACTOR"
    --setenv QT_WAYLAND_FORCE_DPI "$QT_WAYLAND_FORCE_DPI"
    --setenv PLASMA_USE_QT_SCALING "$PLASMA_USE_QT_SCALING"
    --setenv XCURSOR_SIZE "$XCURSOR_SIZE"
    --setenv XCURSOR_THEME "$XCURSOR_THEME"
    --ro-bind /usr/share/icons/ /usr/share/icons/

    # sound (pipewire)
    --ro-bind /run/user/"$UID"/pipewire-0 /run/user/"$UID"/pipewire-0
    # sound (pulseaudio); use it even if using pipewire-pulse.
    --ro-bind /run/user/"$UID"/pulse /run/user/"$UID"/pulse

    # app
    --bind "$XDG_RUNTIME_DIR"/qutebrowser-box/ "$XDG_RUNTIME_DIR"/qutebrowser/

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    "${flags_gui[@]}"

    # ~/.config/qutebrowser as rw is required, otherwise quickmark will fail.
    --bind ~/.config/qutebrowser-box/ ~/.config/qutebrowser/
    --ro-bind ~/.config/qutebrowser/config.py ~/.config/qutebrowser/config.py
    --ro-bind ~/.config/qutebrowser/rc/ ~/.config/qutebrowser/rc/
    --ro-bind ~/.config/qutebrowser/userscripts/ ~/.config/qutebrowser/userscripts/
    --ro-bind ~/.config/qutebrowser/greasemonkey/ ~/.config/qutebrowser/greasemonkey/
    # use separate history.
    --bind ~/.local/share/qutebrowser-box/ ~/.local/share/qutebrowser/
    --bind ~/.cache/qutebrowser-box/ ~/.cache/qutebrowser/
    # app
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

exec bwrap "${flags[@]}" -- "$qutebrowser" "$@"
