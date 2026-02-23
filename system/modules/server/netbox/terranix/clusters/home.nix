{
    resource."netbox_cluster_group"."home" = {
        name = "home";
    };
    resource."netbox_cluster_type"."proxmox" = {
        name = "proxmox";
    };
    resource."netbox_cluster"."home" = {
        name = "Home Proxmox Cluster";
        cluster_type_id = "\${netbox_cluster_type.proxmox.id}";
        cluster_group_id = "\${netbox_cluster_group.home.id}";
    };
}