{ config, ... }:
let
  offsite = config.custom.world.networks.offsite;
in
{
    # Layer-3 subnet for the offsite backup site (where soteria lives). Sourced
    # from lib/world/networks.nix so this stays the single source of truth.
    # No VLAN — the offsite LAN is a flat Xfinity-provided subnet.
    resource."netbox_prefix"."offsite" = {
        prefix = offsite.subnet;
        status = "active";
        site_id = "\${netbox_site.offsite.id}";
        description = "Offsite backup LAN (gateway ${offsite.gateway})";
    };
}
