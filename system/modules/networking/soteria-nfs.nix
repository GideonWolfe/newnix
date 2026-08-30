# This module configures a mountpoint for mounting my Local NAS
{ inputs, config, ... }:
{
  # Provide support for mounting NFS systems
  boot.supportedFilesystems = [ "nfs" ];

  # Defines the mounting for the NFS share
  fileSystems."/soteria/tank" = {
    device = "${config.custom.world.hosts.soteria.wireguard.ip}:/soteria/tank";
    fsType = "nfs";
    options = [ 
      "ro" # Mount read-only on the client (soteria's tank is a backup replica)
      "noauto" # Don't automatically mount at boot
      "x-systemd.automount"  # Mount on access
      "x-systemd.idle-timeout=600" # Unmount after 600 seconds (10 minutes) of inactivity
    ];
  };
}