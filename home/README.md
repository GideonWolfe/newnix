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

## Working with sessions

- Place global, session-agnostic resources in `sessions/global` (environment variables, shared UI defaults, background services such as `blueman-applet`).
- Keep desktop or compositor specific pieces in their own subdirectory (`sessions/hypr`, `sessions/sway`, etc.). Each folder can expose multiple modules (e.g. Hyprland, Hyprpaper, Hyprpanel) so compose only what a host needs.
- Shared UI helpers (Stylix, cursor, GTK/Qt theming) live under `sessions/global/ui` so they can be re-used by every session.

## Adding new structure

If you need a new category:

- Add folders beneath `apps/` or `sessions/` for the low-level module.
- Create or extend a `role` that should aggregate the new module.

Keeping these layers sharp lets you iterate quickly on either half (program configs vs. desktop experience) without surprising regressions elsewhere.
