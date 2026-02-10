# This role is for any machine that lives at my house
# Using this, it is able to mount the NFS shares on my NAS for easy access
{ inputs, ... }:
{
  # Provide support for mounting NFS systems
  boot.supportedFilesystems = [ "nfs" ];

  # Defines the mounting for the NFS share
  fileSystems."/nas/tank" = {
    # TODO: this IP should be a variable, or maybe just an SSH hostname?
    device = "192.168.0.137:/tank";
    fsType = "nfs";
    options = [ 
      "noauto" # Don't automatically mount at boot
      "x-systemd.automount"  # Mount on access
      "x-systemd.idle-timeout=600" # Unmount after 600 seconds (10 minutes) of inactivity
    ];
  };
}