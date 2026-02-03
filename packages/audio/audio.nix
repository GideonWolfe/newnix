{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [
    
    # Package set for all other things audio beyond basic control

    pkgs.blanket # ambient noise player
    #pkgs.piper-tts # Advanced text to speech
    pkgs.audio-sharing # Automatically share the current audio playback in the form of an RTSP stream


    ###########
    # Effects #
    ###########
    pkgs.easyeffects # Sound effects for pipewire apps

    ##############
    # Converters #
    ##############
    pkgs.ffmpeg
    pkgs.soundconverter # sound conversion GUI

    #############
    # Recorders #
    #############
    pkgs.asak # TUI audio player/recorder
    pkgs.audacity
    pkgs.gnome-sound-recorder # simple sound recorder

    ############
    # Analysis #
    ############
    pkgs.sonic-visualiser # sonic analysis tool
    pkgs.friture # real-time audio analyzer

    ##########
    # CD/DVD #
    ##########
    pkgs.asunder # CD ripper GUI
    pkgs.brasero # GNOME CD/DVD burner
    pkgs.flacon # Extracts audio tracks from an audio CD image to separate tracks

    #########
    # Radio #
    #########
    pkgs.shortwave # GNOME internet radio
    pkgs.pyradio # TUI internet radio: run with --no-themes to disable color themes and use system

    ##############
    # Audiobooks #
    ##############
    pkgs.cozy # GNOME audiobook player
    
    ###############
    # Downloaders #
    ###############
    pkgs.spotdl # Download spotify playlists/metadata
    #pkgs.onthespot # download spotify music # unmaintained

    ##################
    # Song ID/Lyrics #
    ##################
    pkgs.mousai # GTK song identifier
    #pkgs.shaq # CLI for Shazam (Song identifier)
    pkgs.swaglyrics # TUI spotify lyrics

    ###############
    # Visualizers #
    ###############
    pkgs.spek # acoustic audio spectrum visualizer
    pkgs.glava
    #pkgs.cava # TUI music visualizer
    pkgs.catnip # more visualizers
    #pkgs.cli-visualizer # another visualizer
    pkgs.projectm-sdl-cpp # more visualizers
    pkgs.cavalier # cava based visualizers
    pkgs.scope-tui # TUI oscilloscope/vectorscope.spectroscope also a music visualizer
    inputs.xyosc.packages.${pkgs.stdenv.hostPlatform.system}.default # another visualizer

  ];
}
