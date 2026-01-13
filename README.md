
Core Design Principles 
1. “Define once, compose everywhere”

Users, roles, package groups, and services are modules, not host configs

Hosts only select modules; they don’t define behavior


high level repository layout

```
.
├── flake.nix
├── flake.lock
│
├── hosts/                     # VERY thin
│   ├── example-host/
│   │   └── default.nix
│   ├── another-host/
│   │   └── default.nix
│
├── users/
│   ├── gideon/
│   │   └── default.nix
│
├── modules/                   # Reusable system modules
│   ├── core/
│   │   ├── base.nix
│   │   ├── locale.nix
│   │   └── nix.nix
│   │
│   ├── hardware/
│   │   ├── amd.nix
│   │   ├── intel.nix
│   │   ├── arm.nix
│   │   └── vm.nix
│   │
│   ├── networking/
│   │   ├── base.nix
│   │   ├── wireguard.nix
│   │   └── tailscale.nix
│   │
│   ├── roles/
│   │   ├── desktop.nix
│   │   ├── server.nix
│   │   ├── headless.nix
│   │   └── laptop.nix
│   │
│   ├── services/
│   │   ├── ssh.nix
│   │   ├── backup.nix
│   │   └── monitoring.nix
│   │
│   └── packages/
│       ├── ai.nix
│       ├── dev.nix
│       ├── media.nix
│       └── cli.nix
│
├── profiles/                  # High-level feature toggles
│   ├── minimal.nix
│   ├── desktop.nix
│   ├── server.nix
│   └── ai-workstation.nix
│
└── lib/
    ├── mkHost.nix
    ├── mkUser.nix
    └── options.nix
```


this is just a hypothetical skeleton, these aren't actual files yet