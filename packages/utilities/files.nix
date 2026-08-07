{ config, lib, pkgs, inputs, ... }:

{
  # CLI-only file/filesystem utilities safe for every host, including
  # headless servers. GUI tools (file-roller, gparted, baobab, czkawka,
  # szyszka, clapgrep, impression, gnome-disk-utility, uefitool) live in
  # packages/utilities/desktop.nix so they don't drag the GTK/GNOME stack
  # onto server VMs.
  environment.systemPackages = with pkgs; [

    # File Operations
    unrar
    unzip
    zip
    p7zip
    file

    # Filesystem Utilities
    ntfs3g # NTFS driver
    gdu # disk usage analyzer TUI
    dysk # better df
    simple-mtpfs # mount cell phone filesystems
    dosfstools # drivers for DOS filesystems
    gptfdisk # GPT partitioning CLI tool, used for wiping new disks
    nfs-utils # NFS commands like showmount and exportfs
    fatrace # monitor filesystem activity

    # Backup CLI
    restic

  ];
}
