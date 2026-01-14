{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Digital Audio Workstations
    reaper # Professional DAW
    zrythm # Free/open source DAW
    mixxx # DJ software
    
    # Plugin frameworks and effects
    yabridge # Yabridge for using Windows VSTs
    yabridgectl
    kapitonov-plugins-pack # LV2 Plugins
    calf # Music plugins (effects, tools, etc)
    infamousPlugins # More LV2 plugins
    
    # Instruments and synthesizers
    drum-machine # GTK drum machine
    helm # Virtual synthesizer
    
    # Guitar processing
    rakarrack # Multi-effects processor emulating pedalboard
    guitarix # Guitar amp engine
    gxpluginx-lv2 # Guitarix plugins
    tonelib-metal # Metal guitar tones
    tonelib-gfx
    tonelib-jam
    proteus # Capture guitar sound and train ML model on it
    tuxguitar # GUI for writing tabs
    powertabeditor # Tab editor for guitar
    

  ];
}

