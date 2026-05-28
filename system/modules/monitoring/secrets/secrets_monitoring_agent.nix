{ ... }:
{
  # Plain push password for the prometheus remote_write receiver.
  # Mode 0444 because alloy runs under DynamicUser.
  sops.secrets."prometheus/push_password" = {
    sopsFile = ./secrets_monitoring_agent.yaml;
    mode = "0444";
  };
}
