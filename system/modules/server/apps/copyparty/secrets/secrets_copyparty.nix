{ ... }:
#
# Copyparty account secret.
#
# The password file is consumed directly by copyparty's systemd preStart
# (replace-secret), which runs as the copyparty service user (gideon) -- so the
# decrypted secret must be owned by that user.
#
{
  sops.secrets."copyparty/copyadmin_password" = {
    sopsFile = ./secrets_copyparty.yaml;
    owner = "gideon";
  };
}
