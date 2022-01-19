# qutebrowser

## run qutebrowser in sandbox (Linux / systemd)

### service unit file

It may be necessary to modify username / groupname.

see [qutebrowser/qutebrowser.service](qutebrowser/qutebrowser.service)

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
