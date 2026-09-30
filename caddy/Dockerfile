FROM caddy:2.11.4-alpine

ARG BUILD_VERSION=1.1.0
ARG BUILD_ARCH
LABEL io.hass.version="${BUILD_VERSION}" \
      io.hass.type="app" \
      io.hass.arch="${BUILD_ARCH}" \
      org.opencontainers.image.title="Caddy for Home Assistant"

ENV XDG_DATA_HOME=/data \
    XDG_CONFIG_HOME=/data/config

COPY Caddyfile /etc/caddy/Caddyfile.default
COPY run.sh /run.sh
RUN apk add --no-cache jq && chmod 0755 /run.sh
WORKDIR /config
ENTRYPOINT ["/run.sh"]
