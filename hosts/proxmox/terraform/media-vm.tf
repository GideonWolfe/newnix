resource "proxmox_vm_qemu" "media_vm" {
  # Set up the info for proxmox
  name = "media-vm"
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
  skip_ipv6 = true

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
    # Extra disk we will use for data
    scsi {
      scsi0 {
        disk {
            size    = "23G"
            storage = "datapool"
            format  = "raw"    # ZFS (zfspool) does not support qcow2
        }
      }
    }
    # Main boot disk copied from template
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