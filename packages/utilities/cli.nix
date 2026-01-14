{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [

    # Tools that improve the command line experience
    # core utils replacements, CLI viewers, etc

    # Navigation
    tree
    eza # better ls (formerly exa)
    zoxide # better cd
    tmux
    screen

    bat # better cat
    bat-extras.batman
    bat-extras.batpipe
    bat-extras.batgrep
    bat-extras.batdiff
    bat-extras.batwatch
    bat-extras.prettybat

    # Utilities
    csview # cat out CSV files
    fd # better find
    lnav # logfile viewer
    sysz # fzf for systemctl
    moreutils # additional unix tools
    fzf
    tldr # better man pages with examples
    ripgrep # better grep
    xcp # better cp
    pstree # process tree
    ov # terminal pager


    espeak # pipe script output to voice



  ];

}
