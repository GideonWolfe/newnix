{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [

    # File Operations
    unrar
    unzip
    file-roller # archive utility
    zip
    p7zip
    czkawka # duplicate file finding GUI
    szyszka # bulk file renamer GUI
    file
    clapgrep # GUI ripgrep

    # Filesystem Utilities
    ntfs3g # NTFS driver
    gparted
    gnome-disk-utility
    gdu # disk usage analyzer TUI
    baobab # disk usage analyzer GUI
    dysk # better df
    impression # GNOME util to quickly burn ISOs
    simple-mtpfs # mount cell phone filesystems
    dosfstools # drivers for DOS filesystems
    uefitool # GUI for manipulating and viewing UEFI firmware files
    gptfdisk # GPT partitioning CLI tool, used for wiping new disks
    nfs-utils # NFS commands like showmount and exportfs

    # Backup CLI
    restic

  ];
}
