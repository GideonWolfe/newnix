
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



# Creating a new host

If I need to get hyper specific, I could add modules individually to build a system

```nix
imports = [
# This host uses my default user configuration
../../users/gideon/default.nix

../../modules/hardware/bluetooth.nix
../../modules/hardware/power.nix
# and so on
];
```

Or, I could throw together a couple roles that describe the system

```nix
imports = [
# This host uses my default user configuration
../../users/gideon/default.nix

# This host is a qemu VM (could be changed to hardware.nix if running on bare metal)
../../roles/qemu-vm.nix

# This host uses the base configuration
#../../roles/base.nix
# This host has a desktop environment and UI
#../../roles/desktop.nix
];

Or, if we have a commonly reused set of roles such as "full workstation" or "headless server", we can use them directly

```nix
imports = [
# This host uses my default user configuration
../../users/gideon/default.nix

# Apply a profile that encompasseses the above setup
../../profiles/minimal-desktop.nix
];
```
