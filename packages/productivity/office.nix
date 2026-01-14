{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [


    ##########
    # OFFICE/#
    ##########
    pkgs.libreoffice
    pkgs.xournalpp # paint.net clone #TODO: theme paper color, etc (need to generate XML)
    pkgs.kdePackages.calligra # suite of productivity apps
    
    ################
    # Spreadsheets #
    ################
    pkgs.visidata # Interactive terminal multitool for tabular data
    pkgs.sc-im # spreadsheet calculator
    
    #################
    # Documentation #
    #################
    pkgs.kiwix # offline viewer for zim files (wikis/docs)
    pkgs.web-archives # offline viewer for zim files (wikis/docs)

    #######
    # PDF #
    #######
    pkgs.zathura # PDF viewer
    pkgs.tdf # TUI PDF viewer
    pkgs.poppler # PDF rendering library
    #pkgs.okular # Documant/PDF viewer
    pkgs.evince # GNOME Documant/PDF viewer

    ############
    # Diagrams #
    ############
    pkgs.drawio # desktop version of draw.io
    pkgs.gaphor # python UML modeling tool
    
    ############
    # Markdown #
    ############
    pkgs.apostrophe # GNOME Markdown editor
    pkgs.frogmouth # advanced TUI markdown reader
    pkgs.glow # TUI markdown quick previewer
    pkgs.mdbook # Create books from markdown # lots of extra addons for this, check package list

    #########
    # LaTeX #
    #########
    #pkgs.texliveFull # full latex environment
    pkgs.texstudio # LaTeX Editor
    pkgs.texliveMinimal # Minimal latex environment


    ######################
    # Dict and Thesaurus #
    ######################
    pkgs.goldendict-ng # GUI dictionary with support for web and local files
    pkgs.artha # offline GKT1 thesaurus
    pkgs.wordbook # GNOME dictionary

  ];
}
