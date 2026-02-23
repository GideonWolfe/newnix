{
    resource."netbox_rack"."home_compute_rack" = {
        name = "Home Compute Rack";
        site_id = "\${resource.netbox_site.home.id}";
        status = "available";
        comments = "Rackmate T2";
        role_id = "\${resource.netbox_rack_role.compute.id}";
        width = 10;
        u_height = 12;
    };
}