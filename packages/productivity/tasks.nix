{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [
    #########
    # TASKS #
    #########
    #pkgs.zanshin
    pkgs.dijo
    # pkgs.gtg depends on caldav -> niquests -> urllib3-future, whose tests
    # currently fail on the updated Python 3.13 toolchain.
    #pkgs.planify # GTK task manager with nextcloud and todoist support
    # pkgs.errands has the same failing caldav dependency chain.
    
  ];
}
