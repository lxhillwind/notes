#!/bin/sh -e

# zenity / pbcopy / pbpaste are required.

qutebrowser="/usr/bin/qutebrowser"

# env variable SANDBOXED_QUTEBROWSER is set in systemd service.
if [ -n "$SANDBOXED_QUTEBROWSER" ]; then
    # systemd $PATH does not contain ~/bin.
    export PATH="$HOME/bin:$PATH"
    exec "$qutebrowser"
else
    # assume it is Linux if systemd (systemctl) is available.
    if ! command -v systemctl >/dev/null; then
        exec "$qutebrowser" "$@"
    fi

    if [ "$1" = "--untrusted-args" ]; then
        shift
    fi

    if ! systemctl status qutebrowser >/dev/null 2>&1; then
        sudo systemctl start qutebrowser
        if [ $# -eq 0 ]; then
            exit
        fi
    fi

    if [ $# -ne 0 ]; then
        zenity --question --width=500 --title='qutebrowser wrapper' --text="copy url?\n\n$*"
        printf %s "$*" | pbcopy
    else
        exec zenity --info --title='qutebrowser wrapper' --text="qutebrowser is already running."
    fi
fi
