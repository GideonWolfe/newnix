{ config, ... }:
let
  sopsFile = ./secrets_youtarr.yaml;
in
{
  sops.secrets = {
    "youtarr-db/password" = { inherit sopsFile; };
    "youtarr-db/root_password" = { inherit sopsFile; };
    "youtarr/username" = { inherit sopsFile; };
    "youtarr/password" = { inherit sopsFile; };
    "youtarr/restic_password" = {
      inherit sopsFile;
      owner = "gideon";
    };
  };

  sops.templates."youtarr-env" = {
    # Recreate the container when its rendered credentials change.
    restartUnits = [ "docker-youtarr.service" ];
    content = ''
      DB_PASSWORD=${config.sops.placeholder."youtarr-db/password"}
      AUTH_PRESET_USERNAME=${config.sops.placeholder."youtarr/username"}
      AUTH_PRESET_PASSWORD=${config.sops.placeholder."youtarr/password"}
    '';
  };

  sops.templates."youtarr-db-env".content = ''
    MARIADB_PASSWORD=${config.sops.placeholder."youtarr-db/password"}
    MARIADB_ROOT_PASSWORD=${config.sops.placeholder."youtarr-db/root_password"}
  '';
}