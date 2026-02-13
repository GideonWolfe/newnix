{ pkgs, ... }:

{
  # Need this to make wayland work with the integrated GPU
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
}
