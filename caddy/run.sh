#!/bin/sh
set -eu

mkdir -p /config /data/config
if [ ! -e /config/Caddyfile ]; then
    cp /etc/caddy/Caddyfile.default /config/Caddyfile
    echo "Created /config/Caddyfile. Edit it to configure your sites."
fi

caddy validate --config /config/Caddyfile --adapter caddyfile
exec caddy run --config /config/Caddyfile --adapter caddyfile
