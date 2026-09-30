# Configuration

Start the app once to create its Caddyfile. The initial configuration serves a
plain HTTP status message, so installation does not expose Home Assistant.

## Edit in Home Assistant

Open **Settings → Apps → Caddy → Configuration**. Enter the complete Caddyfile
in the **Caddyfile** option, save, and restart the app. For multiple lines,
choose **⋮ → Edit in YAML** and use a block string:

```yaml
caddyfile: |
  {
      admin localhost:2019
  }
  :80 {
      respond "Hello from Caddy"
  }
```

The app validates these contents before replacing `/config/Caddyfile`.
Invalid contents stop startup and leave the previous file intact; correct the
option and restart. A nonempty option takes precedence over direct file edits
on every restart. Leave it empty (`caddyfile: ""`) to use the existing file;
clearing the option keeps the last applied contents.

## Edit the file directly

With the Caddyfile option empty, edit `/addon_configs/local_caddy/Caddyfile` using Samba or an editor with access
to app configuration folders. For a repository installation the folder is
`/addon_configs/<repository-id>_caddy`. This folder appears as `/config` inside
the app. Restart the app after saving. Invalid configurations fail startup with
an explanation in the app logs. Existing Caddyfiles are preserved on restart
and upgrade.

## Serve a site with automatic HTTPS

Replace the Caddyfile with the following, changing the domain and email:

```caddyfile
{
    email you@example.com
    admin localhost:2019
}

site.example.com {
    respond "Hello from Caddy"
}
```

Point the domain's DNS A/AAAA records at your public address and forward TCP
ports 80 and 443 on your router to the Home Assistant host. Forward UDP 443 if
you want HTTP/3. Ensure another app is not already using these host ports.
Caddy obtains and renews certificates automatically. Public certificate
issuance requires a reachable domain; incorrect IPv6 records can cause failure.
Certificates and private keys are stored in the persistent `/data/caddy`
directory and included in app backups. Keep backups private.

Caddy forwards WebSockets and the usual proxy headers automatically.

## Reverse proxy any service

Use a reachable LAN address or Supervisor app hostname as the upstream:

```caddyfile
service.example.com {
    reverse_proxy 192.168.1.50:8080
}
```

Replace the example address with your service. `localhost` refers to the Caddy
container, not the Home Assistant host. For plain HTTP on your LAN, use `:80`
instead of a domain name. Each service may require its own proxy settings.

## More sites and existing certificates

Add more site blocks to the same Caddyfile. `/ssl` is mounted read-only for
existing certificates, for example `tls /ssl/fullchain.pem /ssl/privkey.pem`.
The standard Caddy image does not include DNS challenge provider plugins;
wildcard certificates require a custom build with the relevant plugin.

Caddy has no built-in management dashboard. Its admin API listens only on
container loopback and port 2019 is not published. Keep that binding when
customizing the configuration. App logs are visible in Home Assistant.

## Troubleshooting

- Port conflict: stop the conflicting service or change the app's host ports.
  Public ACME validation still needs router ports 80/443 routed appropriately.
- 502 response: check that your upstream service is running and its address,
  protocol, and port are reachable from the Caddy container.
- Failed startup: read the validation error and correct the Caddyfile.
- HTTPS errors: verify DNS, router forwarding, and outbound network access.
