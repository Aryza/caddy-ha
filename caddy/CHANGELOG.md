# Changelog

## 1.1.2

- Restore the Caddyfile option schema so Supervisor retains saved contents.
- Fix version 1.1.1 clearing options after saving.
- Use Edit in YAML for multiline input; the schema must remain enabled.

## 1.1.1

- Open the app Configuration tab as a multiline YAML editor by default.
- Validate option types at startup now that the form schema is disabled.

## 1.1.0

- Add a Caddyfile option to the Home Assistant app Configuration tab.
- Validate configured contents before replacing the existing Caddyfile.
- Keep existing file-based configuration when the option is empty.

## 1.0.0

- Initial app with Caddy 2.11.4.
- Editable Caddyfile, persistent certificate storage, and startup validation.
- HTTP, HTTPS, and HTTP/3 port mappings.
