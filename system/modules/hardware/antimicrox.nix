{ pkgs, ... }:

{
  # add the antimicrox package for gamepad mapping
  environment.systemPackages = with pkgs; [
    antimicrox
  ];

  # Enable user access to uinput for antimicrox keyboard emulation
  # https://github.com/AntiMicroX/antimicrox/blob/master/other/60-antimicrox-uinput.rules
  services.udev.extraRules = ''
    SUBSYSTEM=="misc", KERNEL=="uinput", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';
}
