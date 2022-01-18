# qutebrowser

## run qutebrowser in sandbox (Linux / systemd)

### service unit file

It may be necessary to modify username / groupname.

```sh
# /etc/systemd/system/qutebrowser.service
[Service]
User = lx
Group = lx
Environment = DISPLAY=:0.0 SANDBOXED_QUTEBROWSER=1
ExecStart = /home/lx/bin/qutebrowser
ProtectSystem = strict
PrivateTmp = true
TemporaryFileSystem = /home/lx:uid=1000,gid=1000

# for X11. TODO: wayland?
BindReadOnlyPaths = /home/lx/.Xauthority

# sound requires additional setting, see below.
BindReadOnlyPaths = /home/lx/.config/pulse/
BindPaths = /tmp/pulse-socket

BindPaths = /home/lx/Downloads/
# bind ~/.config/qutebrowser as rw is required, otherwise quickmark will fail.
BindPaths = /home/lx/.config/qutebrowser/ /home/lx/.local/share/qutebrowser/
BindReadOnlyPaths = /home/lx/.config/qutebrowser/config.py /home/lx/.config/qutebrowser/userscripts/
# if rc.py is available, then mount it.
BindReadOnlyPaths = /home/lx/.config/qutebrowser/rc.py
BindReadOnlyPaths = /home/lx/html/

# set ~/bin/qutebrowser explicitly, otherwise it does not work...
BindReadOnlyPaths = /home/lx/bin/qutebrowser /home/lx/bin/ /home/lx/.vimrc /home/lx/vimfiles/
```

### set sudofile for qutebrowser.service

User should be in wheel group.

```console
%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl start qutebrowser
```

### sound setting (pulseaudio)

see <https://wiki.archlinux.org/title/PulseAudio/Examples#Allowing_multiple_users_to_share_a_PulseAudio_daemon>

hint:

- `~/.config/pulse/default.pa`: copy content from `/etc`, then append config
  to it. otherwise it will not start.

- `~/.config/pulse/client.conf`: even though we are running with the same
  user, this is still required.

### update desktop file (optional)

If `~/bin` wins `/usr/bin` in `$PATH` already, then there is no need to modify
desktop file.

### `~/bin/qutebrowser` wrapper script

see [qutebrowser/wrapper.sh](qutebrowser/wrapper.sh)
