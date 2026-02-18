resource "proxmox_vm_qemu" "testy2" {
  # Set up the info for proxmox
  name = "testy2"
  target_node = "pve1"
  vmid = 1003
  clone = "proxmox-base"
  full_clone = true

  # Give the VM some hardware/resource config
  bios = "seabios"
  agent = 1
  scsihw = "virtio-scsi-single"
  os_type = "ubuntu"
  memory = 4096

  cpu {
    type = "host"
    sockets = 1
    cores = 2
  }


  disks {
    # scsi {
    #   scsi0 {
    #     disk {
    #         size    = "30G"
    #         storage = "datapool"
    #         format  = "raw"    # ZFS (zfspool) does not support qcow2
    #     }
    #   }
    # }
    virtio {
      virtio0 {
        disk {
          size    = "30G"
          storage = "datapool"
          format  = "raw"    # ZFS (zfspool) does not support qcow2
        }
      }
    }
  }

#   disks {
#     id = 0
#     storage = "datapool"
#     size = "20G"
#   }
}