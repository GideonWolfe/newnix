{ pkgs, ... }:
{
  programs.xwayland = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
