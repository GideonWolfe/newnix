{ lib, config, ... }:

# The "what to monitor" half of the Gatus module. Every endpoint here is
# derived from lib/world/services.nix, so adding a service to the world
# automatically lands it on the status page - no per-service boilerplate.
let
  svc = config.custom.world.services;
  hosts = config.custom.world.hosts;
  vms = hosts.proxmox.vms;

  # Group each endpoint by the box it runs on so the dashboard mirrors the
  # real topology. Anything unmapped falls back to "Other".
  groupByIp = {
    "${vms.vm_ingress.ip}"  = "Networking";
    "${vms.vm_media.ip}"    = "Media";
    "${vms.vm_app1.ip}"     = "Applications";
    "${vms.vm_app2.ip}"     = "Applications";
    "${vms.vm_test.ip}"     = "Monitoring";
    "${hosts.mnemosyne.ip}" = "Infrastructure";
  };

  # Services with no usable HTTP endpoint (CLI-only tools / sentinel ports),
  # plus Gatus itself (no point self-monitoring the monitor).
  skip = [ "recyclarr" "gatus" ];

  monitorable = lib.filterAttrs
    (name: s: !(builtins.elem name skip) && s.port != 0)
    svc;

  mkEndpoint = name: s: {
    inherit name;
    group = groupByIp.${s.ip} or "Other";
    # Probe the service directly on the LAN. This is the reliable "is the
    # process up and serving" signal and doesn't depend on public DNS, the
    # reverse proxy, or NAT hairpinning being wired up.
    #
    # To instead test the full public path (DNS + TLS + traefik) for services
    # that expose a domain, swap the url for "${s.protocol}://${s.domain}" and
    # add a "[CERTIFICATE_EXPIRATION] > 240h" condition.
    url = "http://${s.ip}:${toString s.port}";
    interval = "1m";
    conditions = [
      "[CONNECTED] == true"
      # Treat anything below 500 as alive: many self-hosted apps answer the
      # root with 200/302/401/403 depending on auth, all of which mean "up".
      "[STATUS] < 500"
    ];
  };
in
{
  custom.monitoring.gatus.settings.endpoints =
    lib.mapAttrsToList mkEndpoint monitorable;
}
