{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    # Enable/install Proton Tricks
    protontricks.enable = true;
    # package = pkgs.steam.override {
    #     extraEnv = {
    #         MANGOHUD="1";
    #         GAMEMODERUN="1";
    #TODO: check these
    #AMD_VULKAN_ICD="RADV";
    #VK3D_CONFIG="dxr,dxr11";
    #PROTON_ADD_CONFIG="fsr4dna3";
    #PROTON_LOCAL_SHADER_CACHE="1";
    #     };
    #
    # };
  };
  # Enable Udev rules for controllers and other hardware
  hardware.steam-hardware.enable = true;
  # Enable Xbox controller driver
  hardware.xone.enable = true;
}
