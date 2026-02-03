{ pkgs, inputs, ... }:
{
    # Use the home module directly; it wires dmsPkgs internally via mkModuleWithDmsPkgs.
    imports = [ inputs.dms.homeModules.dank-material-shell ];

    programs.dank-material-shell = {
        enable = true;
        systemd.enable = true;
        enableSystemMonitoring = false; # avoid dgop dependency not in pkgs
    };
}