{ config, lib, pkgs, ... }:
# Sovol SV08 printer profile for OrcaSlicer
# Import this on hosts that have access to the printer
let
  printerName = "Sovol SV08 0.4 nozzle - Gideon";

  printerProfile = {
    auxiliary_fan = "1";
    from = "User";
    inherits = "Sovol SV08 0.4 nozzle";
    name = printerName;
    printer_extruder_id = [ "1" ];
    printer_extruder_variant = [ "Direct Drive Standard" ];
    printer_settings_id = printerName;
    version = "2.3.2.60";
  };
in
{
  xdg.configFile.orcaslicer-sovol-sv08 = {
    enable = true;
    target = "OrcaSlicer/user/default/machine/${printerName}.json";
    text = builtins.toJSON printerProfile;
  };
}
