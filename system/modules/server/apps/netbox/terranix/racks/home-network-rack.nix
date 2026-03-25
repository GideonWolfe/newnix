{
    resource."netbox_rack"."home_network_rack" = {
        name = "Home Network Rack";
        site_id = "\${resource.netbox_site.home.id}";
        status = "available";
        comments = "Rackmate T1";
        role_id = "\${resource.netbox_rack_role.network.id}";
        width = 10;
        u_height = 4;
    };
}