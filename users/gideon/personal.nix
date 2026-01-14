{ pkgs, inputs, ... }:
# This module can be enabled on a per-system basis
# It extends my basic user to my "personal" user, adding personal accounts
{
  imports = [
    ./configs/calendar/calendar.nix
    ./configs/calendar/calcure.nix
    ./configs/contacts/contacts.nix
  ];
}