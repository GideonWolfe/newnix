
# Repo Architecture

- **system/** – operating-system side configuration (modules → roles → profiles).
- **packages/** – reusable package sets grouped by purpose; consumed by system modules/roles.
- **home/** – Home Manager layer (apps/sessions modules aggregated by roles).
- **users/** – per-user definitions (each imports the desired home roles).

# Creating a new host

If I need to get hyper specific, I could add modules individually to build a system

```nix
imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    ../../system/modules/hardware/bluetooth.nix
    ../../system/modules/hardware/power.nix
    # and so on
];
```

Or, I combine a couple roles that describe the system

```nix
imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # This host is a qemu VM (could be changed to hardware.nix if running on bare metal)
    ../../system/roles/vm-qemu.nix

    # This host uses the base configuration
    ../../system/roles/base.nix
    # This host has a desktop environment and UI
    ../../system/roles/desktop.nix
];
```

Or, if we have a commonly reused set of roles such as "full workstation" or "headless server", we can use them directly

```nix
imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # Apply a profile that encompasses the above setup
    ../../system/profiles/minimal-desktop.nix
];
```

Once our desired system is designed, we add the appropriate Home Manager roles. In our new host's `default.nix`, we can also have

```nix
# Here we could add our full HM configuration (core is automatically imported)
home-manager.users.gideon.imports = [
    ../../home/roles/desktop.nix
];
```

Now all the heavy HM configs such as GUI app themes will be generated as well.