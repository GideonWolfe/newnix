Roles are logical groupings of system `modules` and package sets that work together to fill a role.

For example, a system with the `desktop` role is expected to be a desktop client, so `desktop.nix` imports the modules and packages that provide that experience.

This architecture lets me change things upstream and have every host using that role pick up the change automatically.

Roles that are frequently combined (for example `base`, `desktop`, and `gaming`) can be wrapped in a higher-level profile under `system/profiles/` such as `full-workstation.nix`.