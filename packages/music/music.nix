{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Utilities
    fmit # instrument tuner
    lingot # instrument tuner
    vmpk # Virtual MIDI Piano Keyboard
    piano-rs # TUI piano
    fretboard # guitar chord identifier
    coltrane # Music calculation GUI/TUI
    transcribe # music player optimized for transcribing music
    glicol-cli # TUI for glicol (coding music)
    frescobaldi # Lillypond GUI for writing scores
    kdePackages.minuet # Learn music theory
    solfege # Learn music theory
  ];
}

