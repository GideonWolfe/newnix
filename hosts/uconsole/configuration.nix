{ lib, pkgs, ... }:

let
  backlightPatch = {
    name = "0001-video-backlight-Add-OCP8178-backlight-driver.patch";
    patch = ./patches/0001-video-backlight-Add-OCP8178-backlight-driver.patch;
  };
  panelPatch = {
    name = "0002-drm-panel-add-clockwork-cwu50.patch";
    patch = ./patches/0002-drm-panel-add-clockwork-cwu50.patch;
  };
  amplifierPatch = {
    name = "0003-driver-staging-add-uconsole-simple-amplifier-switch.patch";
    patch = ./patches/0003-driver-staging-add-uconsole-simple-amplifier-switch.patch;
  };
  overlayPatch = {
    name = "0004-arm-dts-overlays-add-uconsole.patch";
    patch = ./patches/0004-arm-dts-overlays-add-uconsole.patch;
  };
  powerPatch = {
    name = "0005-drivers-power-axp20x-customize-PMU.patch";
    patch = ./patches/0005-drivers-power-axp20x-customize-PMU.patch;
  };
  dsiErrorPatch = {
    name = "0006-drm-panel-cwu50-expose-dsi-error-status-to-userspace.patch";
    patch = ./patches/0006-drm-panel-cwu50-expose-dsi-error-status-to-userspace.patch;
  };
in {

  imports = [
    # Defines kernel version and SD card filesystem Layout
    ./hardware-configuration.nix

    # specific hardware configurations for uConsole
    ./uconsole-hardware.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "vc4" "v3d" ];
      # should make above overlay unnecessary
      # not quite, still complains about missing vc4, v3d, ext2, ext4
      #includeDefaultModules = false;
    };

    # Include the necessary kernel patches for uConsole support
    kernelPatches = [
      backlightPatch
      panelPatch
      amplifierPatch
      overlayPatch
      powerPatch
      dsiErrorPatch
    ];

    # for UART debugging
    kernelParams = [ "console=serial0,115200" ];
  };

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nixos-raspberrypi.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };


  ##### PERSONAL STUFF #####

  # override the systemd boot in our default system config
  boot.loader.systemd-boot.enable = lib.mkForce false;

}
