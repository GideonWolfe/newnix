{ config, ... }:
{
  sops.secrets = {
    # Grafana - SMTP (for alert email)
    "grafana/smtp/host"              = { sopsFile = ./secrets_monitoring.yaml; owner = "grafana"; };
    "grafana/smtp/password"          = { sopsFile = ./secrets_monitoring.yaml; owner = "grafana"; };

    # Grafana - admin bootstrap account
    "grafana/users/admin/username"   = { sopsFile = ./secrets_monitoring.yaml; owner = "grafana"; };
    "grafana/users/admin/password"   = { sopsFile = ./secrets_monitoring.yaml; owner = "grafana"; };

    # Grafana - secret_key used to encrypt secrets in Grafana's DB.
    # NixOS 26.05 dropped the built-in default, so this must be provided.
    # Use the OLD default value ("SW2YcwTIb9zpOOhoPsMm") so already-encrypted
    # DB secrets stay readable; store it here rather than hard-coding it.
    "grafana/secret_key"             = { sopsFile = ./secrets_monitoring.yaml; owner = "grafana"; };

    # Grafana - login screen password hint string
    "grafana/hint"                   = { sopsFile = ./secrets_monitoring.yaml; owner = "grafana"; };

    # Prometheus push basic-auth. Hold the bcrypt hash here (prom's
    # --web.config.file wants bcrypt). Generate with:
    #   htpasswd -nBC 10 "" push | cut -d: -f2
    "prometheus/push_password"       = { sopsFile = ./secrets_monitoring.yaml; owner = "prometheus"; };
    # Plain copy of the same password, for the local Grafana datasource.
    "grafana/prometheus_push_password" = { sopsFile = ./secrets_monitoring.yaml; owner = "grafana"; };
  };

  # Web auth file consumed by prometheus via --web.config.file.
  sops.templates."prometheus-web.yml" = {
    owner = "prometheus";
    content = ''
      basic_auth_users:
        push: ${config.sops.placeholder."prometheus/push_password"}
    '';
  };
}
