# This role can be cleanly imported into any configuration that has physical hardware
# Enables use of bluetooth, yubikeys, radios, printers, etc.
# kind of the opposite of the VM role
{ inputs, ... }:
{
  imports = [
    ###########
    # Modules #
    ###########
    ../modules/hardware/bluetooth.nix # Bluetooth support
    ../modules/hardware/ddccontrol.nix # DDC/CI monitor control
    ../modules/hardware/hackrf.nix # HackRF software defined radio support
    ../modules/hardware/i2c.nix # I2C bus support
    ../modules/hardware/power.nix # Power management for laptops
    ../modules/hardware/printing.nix # CUPS and printer support
    ../modules/hardware/ratbagd.nix # Configure gaming mice
    ../modules/hardware/antimicrox.nix # Configure gamepads
    ../modules/hardware/rtl-sdr.nix # RTL-SDR support
    #../modules/hardware/smartd.nix # HDD/SSD S.M.A.R.T monitoring
    #../modules/hardware/scrutiny.nix # Disk health monitoring
    ../modules/hardware/yubikey.nix # Yubikey and smartcard support
    ../modules/hardware/udisks2.nix # Disk automounting
    #../modules/hardware/binfmt.nix # Enable cross-compilation

    ############
    # Packages #
    ############
    ../../packages/utilities/hardware.nix
  ];
}