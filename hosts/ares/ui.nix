{ pkgs, lib, inputs, config, ... }:

{
  # ares is an NVIDIA Optimus laptop (Intel Xe iGPU + RTX 3050 dGPU). By
  # default niri picked the dGPU as its render device (it enumerates as card0),
  # which pins the RTX 3050 at P0 permanently and forces a reverse-PRIME copy of
  # every frame back to the iGPU for scanout - causing choppy, sluggish input.
  #
  # Force niri to render on the Intel iGPU instead. This lets the dGPU fully
  # power down until a game is launched via `nvidia-offload`, and gives games a
  # clean offload path. The by-path node is stable across reboots (unlike
  # renderD12x numbering); PCI 0000:00:02.0 is the Intel iGPU.
  programs.niri.settings.debug.render-drm-device =
    "/dev/dri/by-path/pci-0000:00:02.0-render";

  # Override the scale settings for hyprpanel
  programs.hyprpanel.settings.theme = lib.mkForce {
      bar = {
        scaling = 70;
        dropdownGap = "2.1em";
        menus = {
          menu.notifications.scaling = 70;
          menu.power.scaling = 70;
          menu.dashboard.scaling = 65;
          menu.dashboard.confirmation_scaling = 70;
          menu.clock.scaling = 70;
          menu.battery.scaling = 70;
          menu.blutooth.scaling = 70;
          menu.network.scaling = 70;
          menu.volume.scaling = 70;
          menu.media.scaling = 70;
          tooltip.scaling = 70;
        };
        osd.scaling = 70;
        notification.scaling = 70;
      };
  };

}
