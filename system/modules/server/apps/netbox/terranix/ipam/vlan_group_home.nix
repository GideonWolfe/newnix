{ ... }:
{
    # Site-scoped VLAN group for the Home network. Groups give VLANs a scope
    # (the Home site) and enforce VID uniqueness within it, per NetBox's VLAN
    # management model. New home VLANs should reference this group.
    resource."netbox_vlan_group"."home" = {
        name = "Home";
        slug = "home";
        scope_type = "dcim.site";
        scope_id = "\${netbox_site.home.id}";
        vid_ranges = [ [ 1 4094 ] ];
        description = "VLANs living at the Home site";
    };
}
