{ config, lib, pkgs, ... }:
# Sovol SV08 print process profile for OrcaSlicer
# Import this on hosts that have access to the printer
let
  processName = "0.20mm Standard @Sovol SV08 - Gideon";

  processProfile = {
    brim_type = "auto_brim";
    elefant_foot_compensation = "0.2";
    from = "User";
    inherits = "0.20mm Standard @Sovol SV08";
    name = processName;
    print_extruder_id = [ "1" ];
    print_extruder_variant = [ "Direct Drive Standard" ];
    print_settings_id = processName;
    version = "2.3.2.60";
  };
in
{
  xdg.configFile.orcaslicer-sovol-sv08-process = {
    enable = true;
    target = "OrcaSlicer/user/default/process/${processName}.json";
    text = builtins.toJSON processProfile;
  };
}
