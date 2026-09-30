#!/bin/sh
# Run in the app image: docker run --rm -i --entrypoint sh caddy-ha:dev < tests/cloudflare.sh
set -eu
caddy list-modules | grep -qx dns.providers.cloudflare
mkdir -p /data /config /tmp/test-bin
cat > /tmp/cloudflare.Caddyfile <<'CADDY'
(cloudflare_tls) {
    tls {
        dns cloudflare {env.CF_API_TOKEN}
        resolvers 1.1.1.1 1.0.0.1
    }
}
jellyfin.example.com {
    import cloudflare_tls
    reverse_proxy 192.168.178.31:30015
}
audiobookshelf.example.com {
    import cloudflare_tls
    reverse_proxy 192.168.178.31:30067
}
navidrome.example.com {
    import cloudflare_tls
    reverse_proxy 192.168.178.31:30043
}
CADDY
# Fake credential: validate/provision only, never issue a certificate.
jq -n --rawfile caddyfile /tmp/cloudflare.Caddyfile \
    '{caddyfile: $caddyfile, cloudflare_api_token: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}' > /data/options.json
cat > /tmp/test-bin/caddy <<'WRAPPER'
#!/bin/sh
if [ "$1" = run ]; then
    [ "$CF_API_TOKEN" = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ]
    /usr/bin/caddy adapt --config /config/Caddyfile --adapter caddyfile > /tmp/adapted.json
    jq -e '[.. | objects | select(.name? == "cloudflare") | .api_token] | length > 0 and all(. == "{env.CF_API_TOKEN}")' /tmp/adapted.json >/dev/null
    exit 0
fi
exec /usr/bin/caddy "$@"
WRAPPER
chmod +x /tmp/test-bin/caddy
PATH=/tmp/test-bin:$PATH /run.sh
if grep -q aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa /config/Caddyfile /tmp/adapted.json; then exit 1; fi
# Bad token types are rejected before applying configuration.
jq '.cloudflare_api_token = []' /data/options.json > /tmp/bad-options
mv /tmp/bad-options /data/options.json
if /run.sh > /tmp/error-log 2>&1; then exit 1; fi
echo 'PASS: Cloudflare module, DNS TLS validation, runtime token export, credential-free config, token type rejection'
