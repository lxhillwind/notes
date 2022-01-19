#!/bin/sh

set -e
cd "$(dirname "$0")"
cp /etc/systemd/system/qutebrowser.service ./
