#!/bin/sh

# (put downloaded binary in ~/.artefact)

# additional requirements:
# edit config.yaml:
# - remove unwanted port (like 9090 for external controller);
# - remove inbound type tun and socks (use mixed only);
# - modify inbound listen addr / port.

# cmd:
exec \
bwrap --new-session --die-with-parent --clearenv --ro-bind /etc/ssl/cert.pem /etc/ssl/cert.pem --ro-bind ~/.artefact/mihomo /mihomo --ro-bind ~/.config/mihomo/config.yaml /config.yaml --setenv HOME / --ro-bind ~/.config/clash/Country.mmdb /.config/mihomo/Country.mmdb --unshare-all --share-net --ro-bind /etc/resolv.conf /etc/resolv.conf /mihomo -f /config.yaml

# sample (--user) systemd service file:
#[Unit]
#After = sockets.target
#
#[Service]
## XXX should be replaced by absolute path.
#ExecStart = XXX/bin/mihomo-wrapper
#
#[Install]
#WantedBy = default.target
