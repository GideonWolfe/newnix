{
  sops.secrets."forgejo/restic_password" = {
    sopsFile = ./secrets_forgejo.yaml;
    owner = "gideon";
    group = "users";
    mode = "0400";
  };
}