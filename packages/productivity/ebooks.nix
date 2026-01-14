{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = [
    ##########
    # ebooks #
    ##########
    pkgs.epy # TUI Ebook reader
    pkgs.sigil # ePub editor
    pkgs.foliate # GUI Ebook reader
    pkgs.komikku # GNOME app to discover/read comic books/manga
  ];
}
