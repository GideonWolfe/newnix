# Home modules (v3)

This directory contains the home-manager layer for the third-generation module stack. It now mirrors the host-side architecture (modules → roles) so you can reuse the `gideon` user on any machine while only pulling in the bits that system actually needs.

## Rationale for the layout

- **`apps/` keeps software-specific tweaks together.** Each application, tool, or theme gets its own folder so the module stays focused on that program (e.g. `apps/kitty/kitty.nix`, `apps/nixvim/nixvim.nix`). This keeps updates small and makes it easy to reuse a single app config across machines.
- **`sessions/` owns the desktop environment.** Window-manager helpers, shared Wayland/XDG environment variables, login services, and UI layers that span multiple apps live here. Breaking those pieces out means you can swap Hyprland for Sway (or any future session) without touching the app configs.
- **Roles glue modules together.** They compose app/session modules into larger feature sets (core shell, desktop workstation, etc.).

## Directory map

```
home/
├── README.md              ← This document
├── apps/                  ← Program-level modules & themes
│   ├── shell/             ← Fish, Bash, Starship, helpers
│   ├── kitty/             ← Terminal config
│   ├── ...                ← Other applications
│   └── (one folder per app)
├── roles/                 ← Composable bundles of app/session modules
│   ├── core.nix           ← Shell + base environment
│   └── workstation.nix    ← Desktop + themed apps used on workstations
└── sessions/              ← Desktop/session building blocks
    ├── global/            ← Env vars, XDG dirs, UI primitives
    │   ├── blueman-applet.nix
    │   ├── session-variables.nix
    │   └── ui/ (cursor, GTK/Qt, waybar, etc.)
    ├── hypr/              ← Hyprland + companion daemons
    └── sway/              ← Sway + related services
```

## Working with apps

1. Create a new folder under `apps/<name>/`.
2. Define the module (usually `<name>.nix`; additional files like themes or data are welcome).
3. Decide which role should pull the new module in (or create a new role if it is a brand new category) and add the import there. The base user config (`users/<name>/default.nix`) can import a default role (e.g. `home/roles/core.nix`), while hosts append extra roles through `home-manager.users.<name>.imports` as needed.

Because each module is self-contained, you can remove or override a single app by tweaking just one import line.

### Chromium

[`apps/chromium/chromium.nix`](apps/chromium/chromium.nix) installs uBlock Origin
Lite for ad blocking. Current Chromium requires Manifest V3; classic uBlock
Origin remains configured separately for Firefox.

### Amethyst Mod Manager

[`apps/amethyst/amethyst.nix`](apps/amethyst/amethyst.nix) generates a complete
**Stylix** theme in `~/.config/AmethystModManager/themes/stylix.json`, included
through the `extra` role. After rebuilding, restart Amethyst and select
**Stylix** in its appearance settings. Other application settings remain mutable.

All colors come directly from the Stylix Base16 palette, without blending or
generated shades. The accent uses `base07`, which is lavender in Catppuccin
Mocha. Status colors use the palette's semantic colors on neutral backgrounds;
conflict highlights share a neutral selection color. The generated theme follows
palette changes. Edit the Nix module rather than saving over this Home
Manager-managed theme in Amethyst's theme editor.

### Google Messages

[`apps/google-messages/google-messages.nix`](apps/google-messages/google-messages.nix)
adds a Google Messages launcher through the `extra` role. It imports the Chromium
module and opens Messages in app mode using the existing Chromium profile, sharing
login state and extensions such as Dark Reader. Phone pairing and Dark Reader's
site settings are managed in the browser.

### Tududi

[`apps/tududi/tududi.nix`](apps/tududi/tududi.nix) adds a Tududi launcher through
the `extra` role. It uses Chromium app mode with the existing browser profile.
The URL follows the protocol, IP, and port in `osConfig.custom.world.services.tududi`
from [`lib/world/services.nix`](../lib/world/services.nix), requiring LAN/VPN
access to the service.

### Home Assistant

[`apps/home-assistant/home-assistant.nix`](apps/home-assistant/home-assistant.nix)
adds a Home Assistant launcher through the `extra` role, using Chromium app mode
and the existing browser profile. Its LAN/VPN URL follows the protocol, IP, and
port in `osConfig.custom.world.services.home-assistant` from
[`lib/world/services.nix`](../lib/world/services.nix).

### Dark Reader

[`apps/darkreader/darkreader.nix`](apps/darkreader/darkreader.nix) writes settings
and site fixes directly into the default Firefox profile's Dark Reader storage.
Fully quit Firefox before rebuilding, then reopen it; no manual import is needed.
These settings are declarative, so browser-side changes may be replaced on rebuild.
Home Manager uses Firefox's JSON extension-storage backend for this feature.
Switching from IndexedDB can reset other extensions' local state once, requiring
reconfiguration or sign-in.

The site fixes include a Home Assistant-only correction for the dashboard's
shadow-DOM background. Its address follows the shared service configuration,
and its color follows the Stylix-derived Dark Reader theme. Since Developer
Tools overrides replace all built-in fixes, the module includes a pinned
upstream baseline from Dark Reader 4.9.135. Update that baseline when updating
the extension's site fixes.

Chromium still requires manual imports after rebuilding:

- Import `~/.config/darkreader/config.json` through Dark Reader's settings.
- Open **Developer Tools → Dynamic Theme Editor → Full Editor**, replace the
  contents with `~/.config/darkreader/dynamic-theme-fixes.config`, and click
  **Apply**. This file contains the upstream rules plus the Home Assistant fix;
  keep any additional custom rules in the module so they are not lost.

### Mealie

[`apps/mealie/mealie.nix`](apps/mealie/mealie.nix) adds a Mealie launcher through
the `extra` role, using Chromium app mode with the existing browser profile.
Its LAN/VPN URL follows the protocol, IP, and port in
`osConfig.custom.world.services.mealie`.

### Web app icons and dock matching

The Chromium web app modules install pinned icons from
[Dashboard Icons](https://github.com/homarr-labs/dashboard-icons) into the
user's hicolor icon theme. The [DMS configuration](sessions/global/ui/dms/dms.nix)
maps Chromium's generated window IDs to their desktop entries so the dock uses
the app names and icons. Matches allow different Chromium profile suffixes;
LAN app matches follow the shared service IPs. Chromium omits ports from these
window IDs, so apps on the same host and path cannot be distinguished this way.

After rebuilding, restart DMS if needed. If an app was previously pinned under
its Chromium-generated ID, unpin it and pin the named launcher instead.

## Working with sessions

- Place global, session-agnostic resources in `sessions/global` (environment variables, shared UI defaults, background services such as `blueman-applet`).
- Keep desktop or compositor specific pieces in their own subdirectory (`sessions/hypr`, `sessions/sway`, etc.). Each folder can expose multiple modules (e.g. Hyprland, Hyprpaper, Hyprpanel) so compose only what a host needs.
- Shared UI helpers (Stylix, cursor, GTK/Qt theming) live under `sessions/global/ui` so they can be re-used by every session.

### Niri colors

The [layout module](sessions/niri/layout.nix) uses Stylix colors for window
decorations and the overview. The focus ring is disabled; its workspace-wide
blue-to-orange OKLCH gradient remains configured for optional use.
Active windows have a blue shadow at approximately 15% opacity;
inactive shadows use the theme's neutral background color.

Urgent borders, focus rings, and tab indicators share a red-to-orange OKLab
gradient. Its red endpoint matches the DMS theme's `error` color. The Nix
`urgent.gradient` options generate Niri's `urgent-gradient` settings.

### Kando on Niri

The [Niri bindings](sessions/niri/binds.nix) open Kando's `desktop-menu` with
**Super + right-click**. The command starts Kando if necessary, so no separate
autostart is required. Plain right-click remains available to applications.
This replaces Niri's default Super + right-click window-resize gesture;
Super + left-click still moves windows. Niri does not support desktop-only
mouse bindings.

### Sands timers

The [DMS configuration](sessions/global/ui/dms/dms.nix) enables Sands using its
registry ID, `smartTimer`, and adds its widget next to the clock in the main bar.
After rebuilding, enter `timer 20 min pasta` in the launcher to start a timer.
The `timer` prefix is explicitly configured: Sands defaults to automatic
detection, which lets DMS filter out a generated preview when the full query
contains words absent from that preview (such as `timer` for a named timer).
The bar pill appears only while timers are active; click it for the hourglass
panel. Sands follows the DMS theme and uses PipeWire's `pw-play` for its alarm.
The panel's `+1 min` and `+5 min` buttons adjust an existing timer; they do not
create one. Opening an empty panel via IPC currently exposes an upstream
null-timer error if those controls are clicked. To start a timer without the
launcher, use `dms ipc call smartTimer start "20 min pasta"`.

### Phone Connect

The [DMS configuration](sessions/global/ui/dms/dms.nix) enables Phone Connect
(`dankKDEConnect`) and places its widget in the right-hand bar section. Enabling
the plugin alone does not add its widget to the bar.

### Home Assistant Monitor

The [DMS configuration](sessions/global/ui/dms/dms.nix) enables
`programs.dank-material-shell.plugins.homeAssistantMonitor` from the pinned
plugin registry and adds it to the main bar. Its URL follows
`osConfig.custom.world.services.home-assistant`. The DMS package includes the
plugin's required Qt WebSockets module. Bluetooth uses the stock DMS tile;
Orbit Bluetooth is no longer enabled.

Create a long-lived access token in your Home Assistant profile and add it to
[`gideon_secrets.yaml`](../users/gideon/configs/secrets/gideon_secrets.yaml)
using SOPS, under the nested key:

```yaml
home-assistant:
  token: <long-lived access token>
```

Add the encrypted value before rebuilding: SOPS activation requires the key.
The secret declaration gives your user access to the decrypted file, and
`hassTokenPath` references `osConfig.sops.secrets."home-assistant/token".path`.
The token is read at runtime, never embedded in the Nix configuration or store.
The plugin settings are managed declaratively through
`programs.dank-material-shell.plugins.homeAssistantMonitor.settings`; use the
plugin's entity browser to choose devices and shortcuts.

## Adding new structure

If you need a new category:

- Add folders beneath `apps/` or `sessions/` for the low-level module.
- Create or extend a `role` that should aggregate the new module.

Keeping these layers sharp lets you iterate quickly on either half (program configs vs. desktop experience) without surprising regressions elsewhere.
