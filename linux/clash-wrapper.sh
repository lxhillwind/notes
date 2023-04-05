#!/bin/sh

# build:
# run `go install ...` with CGO_ENABLED=0, so generated binary is static.

# additional requirements:
# Country.mmdb; config.yaml (modify port); ssl.

# cmd:
exec \
bwrap --new-session --die-with-parent --clearenv --ro-bind ~/.sandbox/archlinux/etc/ssl /etc/ssl --ro-bind ~/.sandbox/archlinux/etc/ca-certificates /etc/ca-certificates --ro-bind ~/.sandbox/arch-dev-home/go/bin/clash /clash --ro-bind ~/.config/clash/config.yml /config.yaml --ro-bind ~/.config/clash/Country.mmdb /Country.mmdb --unshare-all --share-net --ro-bind /etc/resolv.conf /etc/resolv.conf /clash -d /

# sample (--user) systemd service file:
#[Unit]
#After = sockets.target
#
#[Service]
## XXX should be replaced by absolute path.
#ExecStart = XXX/bin/clash-wrapper
#
#[Install]
#WantedBy = default.target

# TODO
# - don't know why using :9050 directly in firefox does not work; workaround: use pac.
