# This profile is designed to be the most minimal "desktop" system possible that uses my configuration system
# No productivity packages, no extra utilities, just a basic desktop environment setup

{
    imports = [
        #########
        # Roles #
        #########
        ../roles/base.nix # sets up low level system config
        ../roles/desktop.nix # everything needed to give base desktop experience
    ];
}