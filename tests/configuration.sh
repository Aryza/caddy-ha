#!/bin/sh
# Run inside the app image with: docker run --rm -i --entrypoint sh caddy-ha:dev < tests/configuration.sh
set -eu
mkdir -p /data /config
pid=
trap '[ -z "$pid" ] || kill "$pid" 2>/dev/null || true' EXIT
start_and_check() {
    /run.sh > /tmp/caddy-test.log 2>&1 &
    pid=$!
    n=0
    until wget -qO /tmp/response http://127.0.0.1; do
        n=$((n + 1))
        if [ "$n" -ge 10 ]; then cat /tmp/caddy-test.log; exit 1; fi
        sleep 1
    done
    kill -TERM "$pid"
    wait "$pid"
    pid=
}
# Existing installations may have no caddyfile option.
printf '{}\n' > /data/options.json
start_and_check
cp /config/Caddyfile /tmp/original
cmp /config/Caddyfile /etc/caddy/Caddyfile.default
# Multiline input including literal dollars and quotes must survive JSON parsing.
cat > /tmp/custom <<'CADDY'
{
    admin localhost:2019
}
:80 {
    respond "custom $value" 200
}
CADDY
jq -n --rawfile caddyfile /tmp/custom '{caddyfile: $caddyfile}' > /data/options.json
start_and_check
printf 'custom $value' > /tmp/expected
cmp /tmp/response /tmp/expected
# Blank options preserve the last applied file.
cp /config/Caddyfile /tmp/applied
printf '{"caddyfile":""}\n' > /data/options.json
start_and_check
cmp /config/Caddyfile /tmp/applied
# Invalid configuration must fail without replacing the working file.
printf '{"caddyfile":":80 { definitely_not_a_directive }"}\n' > /data/options.json
if /run.sh > /tmp/caddy-test.log 2>&1; then exit 1; fi
cmp /config/Caddyfile /tmp/applied
[ ! -e /config/.Caddyfile.pending ]
# YAML scalar/list/object mistakes must fail without replacing the file.
for bad in 'null' '42' '[]' '{}'; do
    printf '{"caddyfile":%s}\n' "$bad" > /data/options.json
    if /run.sh > /tmp/caddy-test.log 2>&1; then exit 1; fi
    cmp /config/Caddyfile /tmp/applied
done
echo 'PASS: defaults, multiline input, HTTP response, blank fallback, invalid-input preservation'
