# This role can be cleanly imported into any configuration that has HDDs
# I made this because machines that don't have HDDs error and complain if you try to run smartd/scrutiny
{ inputs, ... }:
{
  imports = [
    ###########
    # Modules #
    ###########
    ../modules/hardware/smartd.nix # HDD/SSD S.M.A.R.T monitoring
    ../modules/hardware/scrutiny.nix # Disk health monitoring
  ];
}