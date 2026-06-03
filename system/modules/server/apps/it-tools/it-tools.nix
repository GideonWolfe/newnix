{ pkgs, lib, config, ... }:

# IT-Tools - a self-hosted collection of handy online tools for developers
# (token generators, encoders, converters, formatters, etc). It's a fully
# static SPA served by nginx inside the container, so there's no DB, no
# state, and no secrets to wire up - hence the deliberately minimal module.
#
# Upstream:        https://github.com/CorentinTh/it-tools
# Container image: ghcr.io/corentinth/it-tools
# Internal port:   80 (nginx)
let
  svc = config.custom.world.services.it-tools;
in
{
  virtualisation.oci-containers.containers.it-tools = {
    # Pin to a released tag rather than `latest` so rebuilds are
    # reproducible. Check available tags at:
    #   https://github.com/CorentinTh/it-tools/pkgs/container/it-tools
    image = "ghcr.io/corentinth/it-tools:2024.5.13-a0bc346";
    autoStart = true;

    # Publish the host port (from world.services) to the container's
    # internal nginx on :80.
    ports = [ "${builtins.toString svc.port}:80" ];

    environment = {
      TZ = "America/New_York";
    };
  };
}
