{config, ... }:
{
    resource."netbox_virtual_machine"."vm_ingress" = {
        name = "ingress";
        cluster_id = "\${netbox_cluster.home.id}";
    };
    resource."netbox_virtual_disk"."vm_ingress_boot_disk" = {
        name = "ingress-vm-boot-disk";
        virtual_machine_id = "\${netbox_virtual_machine.vm_ingress.id}";
        description = "Boot disk for ingress VM";
        size_mb = 30000;
    };
    resource."netbox_virtual_disk"."vm_ingress_data_disk" = {
        name = "ingress-vm-data-disk";
        virtual_machine_id = "\${netbox_virtual_machine.vm_ingress.id}";
        description = "Data disk for ingress VM";
        size_mb = 10000;
    };

    # Define Virtual NIC for the VM
    resource."netbox_interface"."vm_ingress_ether0" = {
        name = "ens18";
        virtual_machine_id = "\${netbox_virtual_machine.vm_ingress.id}";
    };

    # Assign an IP to this VM
    resource."netbox_ip_address"."vm_ingress_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.proxmox.vms.vm_ingress.ip}/24";
        virtual_machine_interface_id = "\${netbox_interface.vm_ingress_ether0.id}";
        status = "active";
    };
    # Make it the primary address
    resource."netbox_primary_ip"."vm_ingress_ip_primary" = {
        virtual_machine_id = "\${netbox_virtual_machine.vm_ingress.id}";
        ip_address_id = "\${netbox_ip_address.vm_ingress_ip1.id}";
    };


    # This VM is reachable over SSH
    resource."netbox_service"."vm_ingress_ssh" = {
        name = "SSH";
        virtual_machine_id = "\${netbox_virtual_machine.vm_ingress.id}";
        protocol = "tcp";
        ports = [22];
    };

    # This VM runs traefik
    resource."netbox_service"."vm_ingress_traefik" = {
        name = "Traefik";
        virtual_machine_id = "\${netbox_virtual_machine.vm_ingress.id}";
        protocol = "tcp";
        ports = [8080 443];
    };
}