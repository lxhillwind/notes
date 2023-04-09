#!/bin/bash
set -e

# seems that we cannot open url inside vscode because of url handler missing.
#
# possible workaround:
# click url in code -> call some program in sandbox -> some program in host get notified by socket
# -> open url in host.

# dbus proxy {{{1
dbus_file=$(printf %s "$DBUS_SESSION_BUS_ADDRESS" | sed 's/unix:path=//; s/,.*//')
mkdir -p /tmp/dbus-proxy
if [ -n "$WAYLAND_DISPLAY" ]; then
    is_wayland=.wayland
else
    is_wayland=
fi
# sway does not kill flock automatically after quiting (unlike x11), so we should use different set.
dbus_file_new=/tmp/dbus-proxy/"${0##*/}$is_wayland"
touch "$dbus_file_new"
dbus_rules=(
    --talk='org.fcitx.Fcitx5'  # fcitx5
    )
# run flock to avoid duplicating xdg-dbus-proxy process;
# run in background, so error check is not required;
flock -xn "$dbus_file_new.flock" \
    xdg-dbus-proxy "$DBUS_SESSION_BUS_ADDRESS" "$dbus_file_new" --filter --log \
    "${dbus_rules[@]}" &
DBUS_SESSION_BUS_ADDRESS="unix:path=$dbus_file_new"

# main {{{1
code="/usr/bin/code"
mkdir -p ~/.code-box/home
mkdir -p ~/.code-box/vscode
mkdir -p ~/.code-box/config
mkdir -p ~/.code-box/cache-fontconfig
mkdir -p ~/.code-box/pki
mkdir -p ~/repos/UNTRUSTED
[ -e ~/.code-box/zshrc ] || printf 'source ~/.config/zshrc\n' >> ~/.code-box/zshrc
[ -e ~/.code-box/electron-flags.conf ] || \
    printf '%s\n%s\n' '--enable-features=UseOzonePlatform' '--ozone-platform=wayland' \
    >> ~/.code-box/electron-flags.conf

flags_archlinux=(
    --ro-bind ~/.sandbox/archlinux/usr /usr
    --ro-bind ~/.sandbox/archlinux/bin /bin
    --ro-bind ~/.sandbox/archlinux/lib64 /lib64
    --ro-bind ~/.sandbox/archlinux/opt/visual-studio-code /opt/visual-studio-code
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

if [ -n "$WAYLAND_DISPLAY" ]; then
    # wayland
    flags_gui=(
        --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
        --ro-bind /run/user/"$UID"/"$WAYLAND_DISPLAY" /run/user/"$UID"/"$WAYLAND_DISPLAY"
        # https://github.com/microsoft/vscode/issues/109176
        # https://wiki.archlinux.org/title/Visual_Studio_Code#Running_natively_under_Wayland
        --ro-bind ~/.code-box/electron-flags.conf ~/.config/code-flags.conf
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
    # fcitx
    --setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS"
    --setenv QT_IM_MODULE "$QT_IM_MODULE" --setenv GTK_IM_MODULE "$GTK_IM_MODULE" --setenv XMODIFIERS "$XMODIFIERS"
    # app
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    --setenv LANG zh_CN.utf8
    --setenv LC_ALL zh_CN.utf8
    --setenv LC_CTYPE zh_CN.utf8

    "${flags_archlinux[@]}"

    --tmpfs /tmp
    --ro-bind "$dbus_file_new" "$dbus_file_new"

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

    # NOTE: (security)
    # --bind a/ then --ro-bind a/b (file), a/b is ro in sandbox;
    # but if we modify a/b (change fd), then a/b will be rw!
    # so, do not use --ro-bind inside --bind.

    --bind ~/.code-box/home ~  # add this before flags_gui because of electron-flags.conf
    "${flags_gui[@]}"

    # app
    --setenv SHELL /bin/zsh
    --bind ~/.code-box/zshrc ~/.zshrc
    --bind ~/.code-box/vscode ~/.vscode
    --bind ~/.code-box/config ~/.config/Code
    --bind ~/.code-box/cache-fontconfig ~/.cache/fontconfig
    --bind ~/.code-box/pki ~/.pki
    --bind ~/repos/UNTRUSTED ~/repos/UNTRUSTED
    --ro-bind ~/.config/zshrc ~/.config/zshrc

    # network.
    --unshare-all --share-net

    # security
    --new-session
    # code is run like daemon mode.
    #--die-with-parent
)

exec bwrap "${flags[@]}" -- "$code" "$@"
