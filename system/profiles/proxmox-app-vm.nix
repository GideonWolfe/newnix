# This profile is designed to be the most minimal system possible that uses my configuration system
# CLI only, no desktop environment, no extra packages
{
    imports = [
        #########
        # Roles #
        #########
        ../roles/base.nix # sets up low level system config
        ../roles/proxmox-vm.nix # proxmox VM role
    ];
}