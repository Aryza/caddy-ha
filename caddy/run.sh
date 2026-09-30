#!/bin/sh
set -eu

mkdir -p /config /data/config
# The YAML editor has no Supervisor form schema, so check option types here.
if [ -f /data/options.json ]; then
    jq -e 'type == "object" and ((has("caddyfile") | not) or (.caddyfile | type == "string"))' /data/options.json >/dev/null || {
        echo "Invalid app options: caddyfile must be a YAML string. Use caddyfile: | for multiline contents." >&2
        exit 1
    }
fi
# A blank option preserves the existing file-based configuration.
if [ -f /data/options.json ] && jq -e '.caddyfile != null and .caddyfile != ""' /data/options.json >/dev/null; then
    candidate=/config/.Caddyfile.pending
    trap 'rm -f "$candidate"' EXIT
    jq -er '.caddyfile | if type == "string" then . else error("caddyfile must be a string") end' /data/options.json > "$candidate"
    caddy validate --config "$candidate" --adapter caddyfile
    mv "$candidate" /config/Caddyfile
    trap - EXIT
    echo "Using Caddyfile from the app configuration."
fi

if [ ! -e /config/Caddyfile ]; then
    cp /etc/caddy/Caddyfile.default /config/Caddyfile
    echo "Created /config/Caddyfile. Edit it to configure your sites."
fi

caddy validate --config /config/Caddyfile --adapter caddyfile
exec caddy run --config /config/Caddyfile --adapter caddyfile
