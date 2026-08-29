{ lib, inputs, ... }: 

{
  imports = [
      # For disk partitioning
      inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk.disk1 = {
      # UGREEN DXP2800 boots from onboard 32GB eMMC (mmcblk0). disko handles
      # the "p" partition suffix (mmcblk0p1, ...) automatically.
      device = lib.mkDefault "/dev/mmcblk0";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # 2GB ESP, small 2GB swap, rest for root.
          # Swap is kept small deliberately: this is a headless NAS with limited
          # 32GB flash, so root disk space matters far more than swap. ZFS ARC
          # lives in RAM and shouldn't be paged; a large swap here would just
          # waste scarce eMMC.
          esp = {
            name = "ESP";
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            name = "swap";
            size = "2G";
            content = {
              type = "swap";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
