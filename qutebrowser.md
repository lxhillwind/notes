# qutebrowser

## run qutebrowser in sandbox (Linux / systemd)

### service unit file

It may be necessary to modify username / groupname.

```console
# /etc/systemd/system/qutebrowser.service
[Service]
User = lx
Group = lx
Environment = DISPLAY=:0.0 SANDBOXED_QUTEBROWSER=1
ExecStart = /home/lx/bin/qutebrowser
ProtectSystem = strict
PrivateTmp = true
TemporaryFileSystem = /home/lx:uid=1000,gid=1000
BindReadOnlyPaths = /home/lx/.Xauthority
BindPaths = /home/lx/Downloads/
BindPaths = /home/lx/bin/qutebrowser /home/lx/.config/qutebrowser/ /home/lx/.local/share/qutebrowser/
BindReadOnlyPaths = /home/lx/.config/qutebrowser/config.py /home/lx/.config/qutebrowser/userscripts/
BindReadOnlyPaths = /home/lx/.config/qutebrowser/rc.py
BindReadOnlyPaths = /home/lx/html/
BindReadOnlyPaths = /home/lx/bin/ /home/lx/.vimrc /home/lx/vimfiles/
```

### update desktop file (optional)

If `~/bin` wins `/usr/bin` in `$PATH` already, then there is no need to modify
desktop file.

### `~/bin/qutebrowser` wrapper script

```sh
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
        printf %s "$*" | pbcopy
        exec zenity --info --title='qutebrowser wrapper' --text="url is copied: $(pbpaste)"
    else
        exec zenity --info --title='qutebrowser wrapper' --text="qutebrowser is already running."
    fi
fi
```
