{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [
    #########
    # TASKS #
    #########
    #pkgs.zanshin
    pkgs.dijo
    pkgs.gtg # Getting Things GNOME (offline task manager)
    #pkgs.planify # GTK task manager with nextcloud and todoist support
    pkgs.errands # official GNOME task manager with nextcloud and ics support
    
  ];
}
