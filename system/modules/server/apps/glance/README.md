# Glance dashboard

Gatus service health above Web, Applications, Media, and Infrastructure bookmarks.
Detailed system metrics remain in Grafana.
Homepage and the separate browser startpage remain unchanged.

## Local development — YAML first

From this directory:

```console
docker compose up -d
```

Open <http://127.0.0.1:8086>. The stock Glance container reads this directory
directly; no Nix build, custom package, or flake output is involved.

- Edit [glance.yml](glance.yml) for bookmarks, layout, and widgets. Glance reloads
	the configuration on save; refresh the browser to see the changes.
- Edit [widgets/gatus-monitor.yml](widgets/gatus-monitor.yml) for the Gatus
	monitor's options and template. Included YAML files also reload on save.
- Edit [assets/stylix.css](assets/stylix.css) for styling. Refresh the browser
	after saving (hard-refresh if the stylesheet is cached).
- [compose.yaml](compose.yaml) exposes only localhost. The bind mount is read-only
	inside the container, but files remain editable on the host.

Stop the container with `docker compose down`; inspect errors with
`docker compose logs glance`.

The URLs and all sixteen theme colors were copied from the current service
registry and Ares's Stylix palette. During development, the YAML and CSS are the
source of truth and do not automatically follow changes in Nix. Icons use
Glance's standard CDN-backed sets. Glance reads Gatus's results rather than
probing each bookmarked service itself.

## Gatus monitor

Adapted from the [community Gatus Monitor by Nedra1998](https://github.com/glanceapp/community-widgets/blob/main/widgets/gatus-monitor/README.md)
(CC0-1.0). It automatically discovers the existing Gatus endpoints and uses the
Stylix status colors. Hover over a status icon for check conditions; click it
to open the endpoint in Gatus.

- `style`: `compact` (default) or `full` (icons, uptime, and response time).
- `duration`: the statistics window, currently `24h`.
- `group`: an exact Gatus group, or an empty string for all groups.
- `compact-metric`: `uptime` or `response-time`.
- `show-failing-only`: hide healthy endpoints; unknown endpoints remain visible.
- `show-only-configured`: require a `<name>-url` override (and an icon in full view).
- Add icons under the exact endpoint name and optional `<name>-url` link overrides.

The option names above match the template; some upstream examples use different
camelCase names. Results are cached for one minute (`cache: 1m`); this is a cache
duration, not a browser auto-refresh interval. Refresh the page for fresh data.
Gatus keeps monitoring independently. Empty histories show an unknown status,
and failed API responses or unmatched filters cannot report an all-clear.

## Convert to Nix later

The earlier [bookmarks.nix](bookmarks.nix), [settings.nix](settings.nix),
[theme.nix](theme.nix), and [glance.nix](glance.nix) are retained as drafts, not
used by the container. Once the dashboard is settled, convert the YAML back to
Nix and restore references to the world registry and Stylix instead of keeping
literal URLs and colors. No native host import or public deployment is enabled.