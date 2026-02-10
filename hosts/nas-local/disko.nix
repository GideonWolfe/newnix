{ lib, inputs, ... }: 

{
  imports = [
      # For disk partitioning
      inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk.disk1 = {
      # TODO change when I figure out right path
      device = lib.mkDefault "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # 2GB EFI System Partition, 8GB swap, rest for root
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
            size = "8G";
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