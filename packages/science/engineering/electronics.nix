{ config, lib, inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    ###############
    # ELECTRONICS #
    ###############
    #BUG: 404 for package
    #pkgs.baudline # scientific signal analysis app
    sigrok-cli # signal analysis software
    pulseview # GUI for sigrok
    sigdigger # Qt-based digital signal analyzer
    #scope-tui # TUI oscilloscope/vectorscope.spectroscope
    picoscope # oscilloscope GUI
    simulide # Simple real time electronic circuit simulator
    kicad-small # PCB designer
    coulomb # GUI circuit simulator

  ];
}
