{ pkgs, lib, config, ... }:

{
  # netbox itself
  services.netbox = {
    enable = true;
    # Bind NetBox on an internal-only port; Nginx will publish the public port.
    port = 4652;
    package = pkgs.netbox;
    # Keep NetBox bound locally; Nginx will publish it.
    listenAddress = "127.0.0.1";
    secretKeyFile = "${config.sops.secrets."netbox/secretkey".path}";
    plugins = python3Packages:
      with python3Packages; [
        netbox-routing
        netbox-floorplan-plugin
        netbox-topology-views
      ];
    settings = {
      LOGIN_REQUIRED = false;
      EXEMPT_VIEW_PERMISSIONS = [ "*" ];
      ALLOWED_HOSTS = [ "*" ];
      USE_X_FORWARDED_HOST = true;
      CSRF_TRUSTED_ORIGINS = [
        "http://localhost:${toString config.custom.world.services.netbox.port}"
        "http://localhost"
        "http://127.0.0.1:${toString config.custom.world.services.netbox.port}"
        "http://127.0.0.1"
        "http://${config.custom.world.services.netbox.ip}:${toString config.custom.world.services.netbox.port}"
        "http://${config.custom.world.services.netbox.ip}"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ config.custom.world.services.netbox.port ];

  # HTTP server required to serve netbox
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    group = "netbox";
    virtualHosts."local-netbox" = {
      listen = [{
        addr = "0.0.0.0";
        port = config.custom.world.services.netbox.port;
      }];

      # Proxy application traffic to NetBox.
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.netbox.port}";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };

      # Serve collected static assets directly.
      locations."/static/" = {
        alias = "${config.services.netbox.dataDir}/static/";
        extraConfig = ''
          autoindex off;
          expires 1h;
        '';
      };
    };
  };
}
