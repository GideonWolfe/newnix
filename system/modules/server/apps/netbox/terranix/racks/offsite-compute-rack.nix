{
    resource."netbox_rack"."offsite_compute_rack" = {
        name = "Offsite Compute Rack";
        site_id = "\${resource.netbox_site.offsite.id}";
        status = "active";
        role_id = "\${resource.netbox_rack_role.compute.id}";
        width = 10;
        u_height = 12;
    };
}
