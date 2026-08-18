{ config, lib, pkgs, ... }:

{
	# Enable gnome-keyring
	services.gnome.gnome-keyring.enable = true;

	# greetd doesn't auto-wire the pam_gnome_keyring module (unlike GDM/SDDM), so
	# the login keyring never unlocks and no Secret Service (org.freedesktop.secrets)
	# runs. This unlocks the `login` keyring with your password at session start,
	# which is what VS Code/Electron needs for its OS keyring.
	security.pam.services.greetd.enableGnomeKeyring = true;

  programs.gnupg = {
      agent = {
          enable = true;
      };
  };

}