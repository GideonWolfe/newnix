{ pkgs, lib, stylix, config, ... }:

{
  programs.gpg.publicKeys = [{ 
    source = ./gideon_pub.asc;
  }];
}
