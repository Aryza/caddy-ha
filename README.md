# Caddy for Home Assistant

A Home Assistant app (formerly called an add-on) that runs Caddy as a web server
and reverse proxy. Requires Home Assistant OS with Supervisor.

## Add to the Home Assistant App Store

In Home Assistant, open
**Settings → Apps → App store → ⋮ → Repositories**, add your GitHub repository
URL `https://github.com/Aryza/caddy-ha`, and refresh the store. Caddy will appear as an installable app.

[Add this repository to Home Assistant](https://my.home-assistant.io/redirect/supervisor_addon/?repository_url=https%3A%2F%2Fgithub.com%2FAryza%2Fcaddy-ha)

## Install locally

1. Copy the `caddy` folder into `/addons/caddy` on your Home Assistant machine
   using Samba or SSH.
2. Open **Settings → Apps → App store**, refresh/check for updates, and find
   **Caddy** under local apps. Older versions call this the Add-on Store.
3. Install and start Caddy. The first installation builds the image locally.
4. Follow [configuration instructions](caddy/DOCS.md).

## Install from a repository

Publish this folder to a GitHub repository, then add that repository URL through
the app store's **Repositories** menu. No prebuilt image is required.

## Development

Build: `docker build --build-arg BUILD_ARCH=amd64 -t caddy-ha:dev caddy`

Validate the bundled configuration:
`docker run --rm --entrypoint caddy caddy-ha:dev validate --config /etc/caddy/Caddyfile.default --adapter caddyfile`

This app includes the Cloudflare DNS provider plugin for private HTTPS. See [Caddy documentation](https://caddyserver.com/docs/) and the
[Home Assistant app specification](https://developers.home-assistant.io/docs/apps/configuration/).
