{ config, ... }:
let
    sopsFile = ./secrets_paperless.yaml;
in
{
    sops.secrets = {
        "paperless/admin_pass" = {
            inherit sopsFile;
            restartUnits = [ "paperless-scheduler.service" ];
    };
        "paperless/restic_password" = {
            inherit sopsFile;
            owner = config.services.paperless.user;
            group = config.users.users.${config.services.paperless.user}.group;
            mode = "0400";
        };
    };
}
