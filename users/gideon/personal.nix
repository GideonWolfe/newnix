{ pkgs, inputs, ... }:
# This module can be enabled on a per-system basis
# It extends my basic user to my "personal" user, adding personal accounts
# Secrets role MUST be enabled on system
{
  imports = [
    # Calendar accounts and sync settings
    ./configs/calendar/calendar.nix
    # Make calcure see them
    ./configs/calendar/calcure.nix
    # Contacts accounts and sync settings
    ./configs/contacts/contacts.nix
    # Email accounts and sync settings
    ./configs/email/email.nix
    # IRC servers and accounts for various clients
    ./configs/irc/halloy.nix
    # RSS feeds and servers
    ./configs/rss/newsboat.nix
    # Creates default gideon thunderbird profile
    ./configs/email/thunderbird.nix
  ];
}