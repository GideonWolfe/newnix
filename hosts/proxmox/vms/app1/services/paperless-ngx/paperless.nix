{ pkgs, lib, config, ... }: {
  networking.firewall = { allowedTCPPorts = [ config.custom.world.services.paperless.port ]; };
  services.paperless = {
    enable = true;
    #passwordFile = config.age.secrets.paperless_admin_pass.path;
    passwordFile = config.sops.secrets."paperless/admin_pass".path;
    port = config.custom.world.services.paperless.port;
    #address = "pngx.gideonwolfe.xyz"; # to access over lan
    address = "0.0.0.0"; # to access over lan
    settings = { 
        PAPERLESS_URL = "${config.custom.world.services.paperless.protocol}://${config.custom.world.services.paperless.domain}";
    };
    # TODO point this at documents dir on NAS
    mediaDir = "";
  };
}