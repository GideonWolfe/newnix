{ pkgs, lib, config, ... }:
let
  # Where my game files are stored on my NAS
  gamesDir = "/nas/tank/media/games/emulation/games";
  # Where my bios files are stored on my NAS. 
  biosDir = "/nas/tank/media/games/emulation/bios/romm/bios";
  # Where in the container RomM expects the game files to be stored. 
  rommRomLibrary = "/romm/library/roms";
  # Where in the container RomM expects the bios files to be stored. 
  rommBiosLibrary = "/romm/library/bios";
in
{
  imports = [
    # SOPS secret declarations for RomM and its database
    ./secrets/secrets_romm.nix
    # Restic backup of RomM data to the NAS
    ./romm_backup.nix
  ];

  # Ensure the romm docker network exists on this host
  systemd.services.docker-create-romm-network = {
    description = "Create romm docker bridge network";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Keep the unit "active (exited)" after success so units that depend on
      # it (the romm containers) see the dependency as satisfied.
      RemainAfterExit = true;
    };
    # Wait for the docker daemon to be reachable before touching networks —
    # `after docker.service` only orders against unit start, not API
    # readiness, so a bare `inspect || create` can misfire during a switch
    # (socket mid-cycle) and die with "network already exists".
    script = ''
      until ${pkgs.docker}/bin/docker info >/dev/null 2>&1; do sleep 1; done
      ${pkgs.docker}/bin/docker network inspect romm-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create romm-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network inspect romm-network >/dev/null 2>&1
    '';
  };

  # Make the auto-generated container units wait for the network to exist.
  systemd.services.docker-romm.after = [ "docker-create-romm-network.service" ];
  systemd.services.docker-romm.requires = [ "docker-create-romm-network.service" ];
  systemd.services.docker-romm-db.after = [ "docker-create-romm-network.service" ];
  systemd.services.docker-romm-db.requires = [ "docker-create-romm-network.service" ];

  virtualisation.oci-containers.containers.romm = {
    image = "rommapp/romm:5.0.0";
    ports = [ "${builtins.toString config.custom.world.services.romm.port}:8080" ];
    autoStart = true;
    # https://docs.romm.app/latest/Getting-Started/Environment-Variables/
    environment = {
      DB_HOST = "romm-db";
      DB_NAME = "romm";
      # Free metadata provider, no API key required
      # https://docs.romm.app/latest/Getting-Started/Metadata-Providers/#hasheous
      HASHEOUS_API_ENABLED = "true";
    };
    volumes = [
      "/data/romm/resources:/romm/resources"
      "/data/romm/redis_data:/redis-data"
      "/data/romm/assets:/romm/assets"
      "/data/romm/config:/romm/config"
      # Bind the games folders to where RomM expects them to be in the container
      "${gamesDir}/gb:${rommRomLibrary}/gb" # GameBoy
      "${gamesDir}/gba:${rommRomLibrary}/gba" # GameBoy Advance
      "${gamesDir}/gbc:${rommRomLibrary}/gbc" # GameBoy Color
      "${gamesDir}/gc:${rommRomLibrary}/ngc" # Nintendo GameCube
      "${gamesDir}/nds:${rommRomLibrary}/nds" # Nintendo DS
      "${gamesDir}/nes:${rommRomLibrary}/nes" # Nintendo Entertainment System
      "${gamesDir}/n64:${rommRomLibrary}/n64" # Nintendo 64
      "${gamesDir}/snes:${rommRomLibrary}/snes" # Super Nintendo Entertainment System
      "${gamesDir}/wii:${rommRomLibrary}/wii" # Nintendo Wii
      "${gamesDir}/wiiu:${rommRomLibrary}/wiiu" # Nintendo Wii U
      "${gamesDir}/md:${rommRomLibrary}/genesis" # megadrive/genesis
      "${gamesDir}/gg:${rommRomLibrary}/gamegear" # game gear
      "${gamesDir}/gw:${rommRomLibrary}/g-and-w" # game and watch
      "${gamesDir}/ngpc:${rommRomLibrary}/neo-geo-pocket-color" # Neo Geo Pocket Color
      "${gamesDir}/sms:${rommRomLibrary}/sms" # Sega Master System
      "${gamesDir}/xbox:${rommRomLibrary}/xbox" # Xbox
      "${gamesDir}/xbox360:${rommRomLibrary}/xbox360" # Xbox 361
      "${gamesDir}/psp:${rommRomLibrary}/psp" # PlayStation Portable
      "${gamesDir}/psvita:${rommRomLibrary}/psvita" # PlayStation Vita
      "${gamesDir}/psx:${rommRomLibrary}/psx" # PlayStation 1
      "${gamesDir}/ps2:${rommRomLibrary}/ps2" # PlayStation 2
      "${gamesDir}/ps3:${rommRomLibrary}/ps3" # PlayStation 3
      "${gamesDir}/ps4:${rommRomLibrary}/ps4" # PlayStation 4
      "${gamesDir}/ps5:${rommRomLibrary}/ps5" # PlayStation 5

      # We already have a specially made bios directory for RomM from 
      # https://github.com/Abdess/retrobios/releases/tag/v2026.04.02
      "${biosDir}:${rommBiosLibrary}" # GameBoy
    ];
    extraOptions = [
      "--network=romm-network"
    ];
    dependsOn = [ "romm-db" ];
    environmentFiles = [ config.sops.templates."romm-env".path ];
  };

  virtualisation.oci-containers.containers.romm-db = {
    image = "mariadb:latest";
    autoStart = true;
    environment = {
      MARIADB_DATABASE = "romm";
    };
    volumes = [
      "/data/romm/romm_database:/var/lib/mysql"
    ];
    extraOptions = [
      "--network=romm-network"
    ];
    environmentFiles = [ config.sops.templates."romm-db-env".path ];
  };

  # Pre-create the bind-mount targets with 1000:100 ownership so docker
  # (which runs as root) doesn't create them as root on first start.
  # romm_database is intentionally omitted: mariadb's entrypoint expects
  # to chown that path itself to its in-container mysql user (999:999),
  # so we let docker create it as root and mariadb fix it up on init.
  systemd.tmpfiles.rules = [
    "d /data/romm            0755 1000 100 - -"
    "d /data/romm/resources  0755 1000 100 - -"
    "d /data/romm/redis_data 0755 1000 100 - -"
    "d /data/romm/assets     0755 1000 100 - -"
    "d /data/romm/config     0755 1000 100 - -"
  ];
}