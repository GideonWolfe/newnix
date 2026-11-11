# Local Glance dashboard

The shared [desktop role](../../../roles/desktop.nix) imports
[glance.nix](glance.nix), enabling a native NixOS service on every desktop client.
After rebuilding the client, open <http://127.0.0.1:8086>.
Glance listens only on loopback and does not open a firewall port.
Homepage and the separate browser startpage remain unchanged.

- [settings.nix](settings.nix) defines the layout and search widget.
- [bookmarks.nix](bookmarks.nix) defines the bookmarks. Internal services use
  registry IPs and backend HTTP ports rather than public Traefik domains.
  Proxmox management links use HTTPS; public websites keep their domains.
- [theme.nix](theme.nix) generates the stylesheet from each client's complete
  Stylix palette and disables the theme picker.
- [widgets/gatus-monitor.nix](widgets/gatus-monitor.nix) configures the Gatus
  widget using the registry's IP and port.
- [widgets/gatus-monitor.html](widgets/gatus-monitor.html) contains its Go/HTML
  template, adapted from the
  [community Gatus Monitor by Nedra1998](https://github.com/glanceapp/community-widgets/blob/main/widgets/gatus-monitor/README.md)
  (CC0-1.0).

All configuration is declared in Nix; NixOS generates Glance's runtime YAML.
There is no handwritten YAML or Compose deployment to maintain.
Apply changes with your usual NixOS rebuild. Inspect service errors with
`journalctl -u glance` and check its state with `systemctl status glance`.
Stop the old development container before switching if it still owns port 8086.

## Gatus monitor

Glance reads the existing Gatus API rather than probing services itself.
The client needs LAN/VPN access to Gatus and the bookmarked internal services.
Hover over a status icon for check conditions; click it for endpoint details.

Widget options:

- `style`: `compact` (default) or `full` (icons, uptime, response time).
- `duration`: statistics window, currently `24h`.
- `group`: exact Gatus group, or an empty string for all groups.
- `compact-metric`: `uptime` or `response-time`.
- `show-failing-only`: hide healthy endpoints; unknown endpoints remain visible.
- `show-only-configured`: require a `<name>-url` override (and a full-view icon).
- Endpoint-name options set icons; `<name>-url` options override detail links.

Results are cached for one minute, not automatically refreshed in the browser.
Refresh the page for fresh data. Empty histories show unknown status; failed API
responses and unmatched filters never report an all-clear.
