# Native Betaflight App

[default.nix](default.nix) packages the official **Betaflight App 2026.6.2**
Linux amd64 release, pinned by version and SHA-256 hash. This is the native
Tauri/GTK3 application, not a browser launcher or the old NW.js Configurator.
Only `x86_64-linux` is supported by this release asset.

The [electronics package set](../../science/engineering/electronics.nix)
installs it instead of nixpkgs' `betaflight-configurator` 10.10.0. That older
app only supports firmware APIs through 1.46; the Meteor75 Pro II's
Betaflight 2025.12.5 uses API 1.47.

## Installation and use

Include this new package directory in Git before a normal Git-filtered flake
rebuild, then rebuild the workstation normally. No extra flake output, overlay,
or development shell is required.

- Application launcher: **Betaflight**
- Command: `betaflight-app`
- Compatibility command: `betaflight-configurator` launches the same new app.

The package patches the binary's interpreter and library paths for Nix and
wraps it with GTK/WebKit and GStreamer discovery settings. It retains the
upstream desktop entry and icon. It does not change flight-controller firmware,
settings, or radio bindings.

Serial access uses the existing `dialout` group membership. Close other apps'
connections to the same port before connecting. No additional udev rules or
relaxed device permissions are installed; DFU/flashing permissions are separate
from ordinary serial access and were not tested here.

The native app's preferences are separate from the browser and legacy
Configurator. Reapply interface preferences such as Expert Mode as needed.

## Updating the pin

1. Choose a stable version from the [official releases](https://github.com/betaflight/betaflight-configurator/releases).
2. Update `version` in [default.nix](default.nix). Confirm that the release still
   provides the `Betaflight-<version>-amd64.deb` asset used by the URL.
3. Obtain the new asset's hash with `nix store prefetch-file --json <asset-url>`
   and copy its `hash` value into the derivation.
4. Build and smoke-test the package before rebuilding the workstation. Check
   that the app still supports the aircraft's firmware API; do not bypass its
   compatibility checks.

Updating flake inputs alone does **not** advance this application version.
It never downloads a floating "latest" release at launch.

To build only this package, run from the repository root:

```sh
nix build --impure --no-write-lock-file --no-link --print-out-paths --expr '
  let
    flake = builtins.getFlake ("path:" + toString ./.);
    pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
  in pkgs.callPackage ./packages/custom/betaflight { }
'
```

This uses the repository's pinned Nixpkgs and includes untracked files for the
test build without changing the lock file.

## Validation

- The build fails if `autoPatchelfHook` cannot resolve required ELF libraries.
- Install checks validate the desktop entry, both commands, and the icon.
- Version 2026.6.2 was built and its welcome screen rendered successfully under
  niri/Wayland on ares. The startup test used an isolated profile with serial
  devices hidden; it did not connect to or modify the aircraft.

For manual checks, keep the flight battery disconnected unless it is actually
needed. Never run motor tests with props installed.