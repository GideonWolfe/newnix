{ config, lib, pkgs, ... }:

# https://github.com/TechJeeper/Printventory — catalog existing models without moving them.
let
  svc = config.custom.world.services.printventory;
  dataDir = "/data/printventory";
  modelsDir = "/nas/tank/personal/gear";
in
{
  systemd.services.docker-printventory = {
    # Require the real data/NFS mounts; never scan an empty, unmounted directory.
    unitConfig.RequiresMountsFor = [ dataDir modelsDir ];
    preStart = ''
      if ! [ -d ${lib.escapeShellArg modelsDir} ]; then
        echo "Printventory source directory is missing; refusing to start." >&2
        exit 1
      fi
      # Upstream runs as root and chmods its config; keep the parent private.
      ${pkgs.coreutils}/bin/install -d -m 0700 \
        ${lib.escapeShellArg dataDir} ${lib.escapeShellArg "${dataDir}/config"}
    '';
  };

  virtualisation.oci-containers.containers.printventory = {
    image = "docker.io/printventory/printventory:2.2.15@sha256:ab20aa05aba52d8e2aabdd79e7810973ae5385bfa36ad3c300a7cb0eb4afcb19";
    autoStart = true;
    ports = [ "${svc.ip}:${builtins.toString svc.port}:5000" ];

    environment = {
      TZ = config.time.timeZone;
      STL_HOME = "/models";
      # Keep the scan root and internal port declarative across restarts.
      PRINTVENTORY_ENV_OVERRIDES_SETTINGS = "1";
      PRINTVENTORY_PORT = "5000";
      PRINTVENTORY_GPU = "swiftshader";
    };

    volumes = [
      "${dataDir}/config:/root/.config/printventory"
      # Read-only at the filesystem boundary, including delete/move actions in the UI.
      "${modelsDir}:/models:ro"
    ];
    extraOptions = [
      "--cap-drop=ALL"
      "--security-opt=no-new-privileges=true"
      # Preserve NAS group read access even when NFS squashes container root.
      "--group-add=${builtins.toString config.users.groups.users.gid}"
      # Bound headless Electron's thumbnail work on the shared application VM.
      "--memory=4g"
      "--cpus=2"
    ];
  };

  networking.firewall.allowedTCPPorts = [ svc.port ];
}
