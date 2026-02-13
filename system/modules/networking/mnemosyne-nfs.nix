# This module configures a mountpoint for mounting my Local NAS
{ inputs, config, ... }:
{
  # Provide support for mounting NFS systems
  boot.supportedFilesystems = [ "nfs" ];

  # Defines the mounting for the NFS share
  fileSystems."/nas/tank" = {
    device = "${config.custom.world.hosts.mnemosyne.ip}:/tank";
    fsType = "nfs";
    options = [ 
      "noauto" # Don't automatically mount at boot
      "x-systemd.automount"  # Mount on access
      "x-systemd.idle-timeout=600" # Unmount after 600 seconds (10 minutes) of inactivity
    ];
  };
}