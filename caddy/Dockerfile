FROM caddy:2.11.4-builder-alpine AS builder
RUN xcaddy build v2.11.4 --with github.com/caddy-dns/cloudflare@v0.2.4

FROM caddy:2.11.4-alpine

ARG BUILD_VERSION=1.2.0
ARG BUILD_ARCH
LABEL io.hass.version="${BUILD_VERSION}" \
      io.hass.type="app" \
      io.hass.arch="${BUILD_ARCH}" \
      org.opencontainers.image.title="Caddy for Home Assistant"

ENV XDG_DATA_HOME=/data \
    XDG_CONFIG_HOME=/data/config

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile.default
COPY run.sh /run.sh
RUN apk add --no-cache jq && chmod 0755 /run.sh
WORKDIR /config
ENTRYPOINT ["/run.sh"]
