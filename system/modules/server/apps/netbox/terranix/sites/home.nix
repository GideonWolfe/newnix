{config, ...}:
{
    resource."netbox_site"."home" = {
        name = "Home";
        status = "active";
        latitude = "${builtins.toString config.custom.world.locations.nyc.lat}";
        longitude = "${builtins.toString config.custom.world.locations.nyc.long}";
    };
}