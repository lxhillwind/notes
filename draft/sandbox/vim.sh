#!/bin/bash
set -e

# TODO: plugin dir.

# bwrap (bubblewrap) is required.

if ! command -v bwrap >/dev/null; then
    echo 'bwrap required!' >&2
    exit 1
fi

flags=(
    # env:
    --clearenv
    # basic
    --setenv PATH "$HOME/app/vim/bin":"$HOME/bin":/bin --setenv USER "$USER" --setenv HOME ~
    # app
    --setenv SANDBOXED_VIM 1

    # lib and bin
    --ro-bind /usr /usr --ro-bind /lib64 /lib64 --ro-bind /bin /bin
    --tmpfs /tmp

    # proc, sys, dev
    --proc /proc
    # --ro-bind /sys /sys; see https://wiki.archlinux.org/title/Bubblewrap
    --ro-bind /sys/dev/char /sys/dev/char
    --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    --dev /dev

    # network (also --share-net)
    --ro-bind /etc/resolv.conf /etc/resolv.conf

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    # app
    --setenv TERM xterm-256color
    --bind "$HOME/.sandbox/一个不容易误进的文件夹 (real)/vim/" ~
    --ro-bind ~/.vimrc ~/.vimrc
    --ro-bind ~/vimfiles/ ~/vimfiles/
    --ro-bind ~/.config/env.sh ~/.config/env.sh

    # network.
    --unshare-all --share-net
)

exec bwrap "${flags[@]}" -- ~/app/vim/AppRun "$@"
