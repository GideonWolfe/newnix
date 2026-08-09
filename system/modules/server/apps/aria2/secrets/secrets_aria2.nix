{ ... }:
#
# Aria2 RPC secret.
#
# The token is handed to the aria2 service via systemd LoadCredential (read
# by root during preStart), so it does not need special ownership -- the
# default root:root 0400 is fine.
#
{
  sops.secrets."aria2/rpc_token" = {
    sopsFile = ./secrets_aria2.yaml;
  };
}
