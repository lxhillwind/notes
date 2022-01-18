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
BindPaths = /home/lx/.config/qutebrowser/ /home/lx/.local/share/qutebrowser/
BindReadOnlyPaths = /home/lx/.config/qutebrowser/config.py /home/lx/.config/qutebrowser/userscripts/
BindReadOnlyPaths = /home/lx/.config/qutebrowser/rc.py
BindReadOnlyPaths = /home/lx/html/
BindReadOnlyPaths = /home/lx/bin/qutebrowser /home/lx/bin/ /home/lx/.vimrc /home/lx/vimfiles/
```

### set sudofile for qutebrowser.service

User should be in wheel group.

```console
%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl start qutebrowser
```

### update desktop file (optional)

If `~/bin` wins `/usr/bin` in `$PATH` already, then there is no need to modify
desktop file.

### `~/bin/qutebrowser` wrapper script

see [qutebrowser/wrapper.sh](qutebrowser/wrapper.sh)
