# This role can be cleanly imported into any configuration that is running as a REGULAR local qemu VM
# not guaranteed to work if used in a VPS or proxmox environment.
{ inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ];
}