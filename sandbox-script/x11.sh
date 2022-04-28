#!/bin/bash
set -e

x11="/usr/bin/startxfce4"
xephyr_jid=

for i in bwrap Xephyr xauth; do
    if ! command -v "$i" >/dev/null; then
        printf '%s not found!\n' "$i" >&2
        exit 1
    fi
done

# disable fcitx; it may cause security issue in x11.

if :; then
    num=12
    _DISPLAY=:"$num"
    _XAUTHORITY=~/.sandbox/xauth

    if ! [ -e "$_XAUTHORITY" ]; then
        # generate auth file.
        xauth -f .sandbox/xauth add "$_DISPLAY" . "$(hexdump -n 16 -e '4/4 "%08x"' /dev/urandom)"
    fi

    # start xephyr if not started.
    if ! [ -S /tmp/.X11-unix/X"$num" ]; then
        Xephyr "$_DISPLAY" -auth "$_XAUTHORITY" -fullscreen -no-host-grab &
        xephyr_jid=$!
    fi

    # x11
    flags_gui=(
        --setenv DISPLAY "$_DISPLAY"
        --ro-bind "$_XAUTHORITY" ~/.Xauthority
    )
fi

flags=(
    # env:
    --clearenv
    # basic
    --setenv PATH /usr/bin --setenv USER "$USER" --setenv HOME ~
    # app
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    --setenv SANDBOXED_QUTEBROWSER 1
    --setenv SHELL /bin/zsh
    --setenv LANG zh_CN.UTF-8  # local-gen required.
    --setenv PATH "$HOME"/bin:/usr/bin  # ~/bin at first.
    # fcitx: we are using container's, not hosts'.
    --setenv QT_IM_MODULE "$QT_IM_MODULE" --setenv GTK_IM_MODULE "$GTK_IM_MODULE" --setenv XMODIFIERS "$XMODIFIERS"

    # lib and bin
    --ro-bind ~/.sandbox/archlinux/usr /usr
    --ro-bind ~/.sandbox/archlinux/lib64 /lib64
    --ro-bind ~/.sandbox/archlinux/usr/bin /bin
    --ro-bind ~/.sandbox/archlinux/opt/visual-studio-code/ /opt/visual-studio-code/
    --ro-bind ~/.sandbox/archlinux/etc /etc
    --tmpfs /tmp
    # fix qt app warning.
    --perms 0700 --tmpfs "$XDG_RUNTIME_DIR"

    # proc, sys, dev
    --proc /proc
    # --ro-bind /sys /sys; see https://wiki.archlinux.org/title/Bubblewrap
    --ro-bind /sys/dev/char /sys/dev/char
    --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    --dev /dev
    # for webgl
    --dev-bind /dev/dri/ /dev/dri/

    # network (also --share-net)
    --ro-bind /etc/resolv.conf /etc/resolv.conf

    --bind ~/.sandbox/app/arch-x11 ~
    --ro-bind ~/dotfiles/ /opt/repos/dotfiles/
    --ro-bind ~/wiki/ /opt/repos/wiki/

    "${flags_gui[@]}"

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    # network.
    --unshare-all --share-net

    # security
    --new-session --die-with-parent
)

bwrap "${flags[@]}" -- "$x11" "$@"
if [ -n "$xephyr_jid" ]; then
    kill $xephyr_jid
fi
