{ inputs, ... }:
{
  # dms-greeter: a greetd login screen matching the DankMaterialShell aesthetic.
  # The upstream flake ships a standalone NixOS module that also wires up greetd.
  imports = [ inputs.dank-greeter.nixosModules.default ];

  programs.dms-greeter = {
    enable = true;
    # Render the greeter inside niri (our primary compositor).
    compositor.name = "niri";
    # Copy gideon's DMS theme, wallpaper, and settings into the greeter so the
    # login screen matches the desktop.
    configHome = "/home/gideon";
  };
}
