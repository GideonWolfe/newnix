{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [

    # Basic packages for audio management and control.
    # Should be imported by any system that plans on using sound.

    ##################
    # Audio Controls #
    ##################
    pkgs.qpwgraph # QT patchbay for pipewire
    pkgs.helvum # GTK patchbay for pipewire
    pkgs.coppwr # Low level control GUI for pipewire
    pkgs.pwvucontrol # volume control gui (pipewire)
    pkgs.pavucontrol # PulseAudio control GUI (pulse)
    pkgs.playerctl # MPRIS control CLI

    #######################
    # System Audio Utils  #
    #######################
    pkgs.pipewire
    pkgs.pulseaudio # included to get pactl, not actually running via hardware.pulseaudio
    pkgs.alsa-utils # amixer and other utilities

  ];
}
