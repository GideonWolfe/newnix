{ pkgs, ... }:
{
  programs.sway = {
    # Enable Sway
    enable = true;
  };

  # Add Sway to the display manager sessions
  services.xserver.displayManager = {
    session = [
      {
        manage = "window";
        name = "sway";
        start = "${pkgs.sway}/bin/sway";
      }
    ];
  };

  # required for sway according to docs
  security.polkit.enable = true;
  # Required for swaylock to work
  security.pam.services.swaylock = {
    text = "	auth include login\n";
  };
}
