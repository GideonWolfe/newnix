{ pkgs, lib, ... }:
{
  # Boot splash
  boot.plymouth = {
    enable = true;
    # Pass in the package of themes we also downloaded
    themePackages = [ pkgs.adi1090x-plymouth-themes ];
    # Choose the theme (can be overidden by the host if desired)
    # https://github.com/adi1090x/plymouth-themes
    theme = lib.mkDefault "motion";
  }; 
}
