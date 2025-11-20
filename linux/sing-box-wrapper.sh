#!/bin/sh

# (put downloaded binary in ~/.artefact)

# additional requirements:
# edit config.json:
# - remove unwanted port (like 9090 for external controller);
# - remove inbound type tun and socks (use mixed only);
# - modify inbound listen addr / port.

# cmd:
exec \
bwrap --new-session --die-with-parent --clearenv --ro-bind /etc/ssl/cert.pem /etc/ssl/cert.pem --ro-bind ~/.artefact/sing-box /sing-box --ro-bind ~/.config/sing-box/config.json /config.json --unshare-all --share-net --ro-bind /etc/resolv.conf /etc/resolv.conf --setenv ENABLE_DEPRECATED_SPECIAL_OUTBOUNDS true --setenv ENABLE_DEPRECATED_TUN_ADDRESS_X true /sing-box -c /config.json run

# sample (--user) systemd service file:
#[Unit]
#After = sockets.target
#
#[Service]
## XXX should be replaced by absolute path.
#ExecStart = XXX/bin/sing-box-wrapper
#
#[Install]
#WantedBy = default.target

# TODO
# - don't know why using :9050 directly in firefox does not work; workaround: use pac.
