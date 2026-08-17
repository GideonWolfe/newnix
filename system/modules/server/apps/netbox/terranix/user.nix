{config, ... }:
{
    variable."netbox_username" = {
        type = "string";
    };
    variable."netbox_password" = {
        type = "string";
    };
    variable."netbox_user_token" = {
        type = "string";
    };

    resource."netbox_user"."test" = {
        username = "\${var.netbox_username}";
        password = "\${var.netbox_password}";
        active = true;
        staff = true;
    };

    resource."netbox_token"."test_basic" = {
        user_id = "\${netbox_user.test.id}";
        key = "\${var.netbox_user_token}";
    };
}