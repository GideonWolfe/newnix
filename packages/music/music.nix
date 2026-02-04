{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    #############
    # Utilities #
    #############
    fmit # instrument tuner
    lingot # instrument tuner
    vmpk # Virtual MIDI Piano Keyboard
    piano-rs # TUI piano
    fretboard # guitar chord identifier
    coltrane # Music calculation GUI/TUI
    transcribe # music player optimized for transcribing music
    glicol-cli # TUI for glicol (coding music)
    # BUG: has CVE preventing build
    #frescobaldi # Lillypond GUI for writing scores
    kdePackages.minuet # Learn music theory
    solfege # Learn music theory

    ##################
    # Music Taggers  #
    ##################
    pkgs.eartag # GNOME GUI for editing audio metadata
    pkgs.easytag # GUI for editing audio metadata
    pkgs.picard # musicbrainz tagger

    ##################
    # Music Players  #
    ##################
    #pkgs.spotify # disabled because stylix/spicetify install the binary
    pkgs.cmus # TUI music player
    pkgs.termusic # TUI music player
    pkgs.termsonic # TUI subsonic client
    pkgs.fum # MPRIS TUI client
    #pkgs.sublime-music #GUI Subsonic music server client #BUG: this one slow as fuck
    #pkgs.feishin # GUI Subsonic music server client #TODO: rewritten into audioling, not a package yet
    #pkgs.finamp # Jellyfin music player
    #pkgs.supersonic # subsonic client https://github.com/dweymouth/supersonic/blob/main/res/themes/default.toml
    #pkgs.amarok # KDE GUI music player
    #pkgs.deadbeef-with-plugins # GUI music player unmaintained, might need to just use deadbeef
    pkgs.decibels # GNOME simple audio player GUI

  ];
}

