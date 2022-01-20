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

- `~/.config/pulse/default.pa`: copy content from `/etc`, then append config
  to it. otherwise it will not start. (or include conf from vendor config)

```
#!/usr/bin/pulseaudio -nF

.fail
.include /etc/pulse/default.pa
.fail

load-module module-native-protocol-unix auth-group=GROUP_NAME socket=/tmp/pulse-socket
```

- `~/.config/pulse/client.conf`: even though we are running with the same
  user, this is still required.

```
default-server = unix:/tmp/pulse-socket
```

### update desktop file (optional)

If `~/bin` wins `/usr/bin` in `$PATH` already, then there is no need to modify
desktop file.

### `~/bin/qutebrowser` wrapper script

This script is used to make desktop file work (open url in sandboxed
qutebrowser).

see [qutebrowser/wrapper.sh](qutebrowser/wrapper.sh)
