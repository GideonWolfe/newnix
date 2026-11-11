{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

{
	programs.chromium = {
		enable = true;
        extensions = [
            # uBlock Origin Lite (Manifest V3)
            {
                id = "ddkjiahejlhfcafbddmgiahcphecmpfh";
            }
            # DarkReader
            {
                id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
            }
            # Vimium
            {
                id = "dbepggeogbaibhgnhhndojpepiihcmeb";
            }
            # New Tab Redirect
            {
                id = "fjmejipbaegkajpfkghaapfhdempldpd";
            }
        ];
	};
}
