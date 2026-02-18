resource "proxmox_vm_qemu" "testy" {
  # Set up the info for proxmox
  name = "testy"
  target_node = "pve1"
  vmid = 1002
  clone = "proxmox-base"
  full_clone = true
  skip_ipv6 = true

  # Give the VM some hardware/resource config
  bios = "seabios"
  agent = 1
  scsihw = "virtio-scsi-single"
  os_type = "ubuntu"
  memory = 4096

  # Give the VM CPU
  cpu {
    type = "host"
    sockets = 1
    cores = 2
  }

  # Connect the VM to the default NIC
  network {
    model  = "virtio"
    bridge = "vmbr0"
    id     = 0        # first NIC
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
    # Carry over the OS disk from the template
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
}