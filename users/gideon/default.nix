{ pkgs, ... }:

{
  users.users.gideon = {
    home = "/home/gideon";
    description = "Gideon";
    isNormalUser = true;
    shell = pkgs.fish;
    initialHashedPassword = "$6$vfx95FxcFJ8bw1vC$vYI9YPln6V/rm3hV9XT/FiK1tsP64O78KsSFgF9Auk7xbGmdaXDY5A49nXZ77wIArh19RuPQ1SdzP2Nd/lzhi.";
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker" # Let the user run docker commands
      "libvirtd" # Let the user manage virtual machines
      "dialout" # let programs run by the user (like chirp) access USB ports
      "input" # let programs run by the user (like chirp) access touchpad input (for fusuma gestures)
      "i2c"       # allow the user to control i2c devices like external displays through ddc
      "plugdev" # for RTL-SDR
      "storage" # for udiskie
    ];
  };

  # Allow gideon to copy closures (trusted user for nix operations)
  nix.settings.trusted-users = [ "gideon" ];

  # Basic Home-Manager setup
  home-manager.users.gideon = { inputs, ... }: {
    home.username = "gideon";
    home.homeDirectory = "/home/gideon";
    home.stateVersion = "25.11";

    programs.home-manager.enable = true;

    # Put my profile image in the usual spot
    home.file."profile.png".source = ./profile.png;

    imports = [
      # Import my core HM configs (shell stuff mostly) on every system
      ../../home/roles/core.nix
    ];
  };
}