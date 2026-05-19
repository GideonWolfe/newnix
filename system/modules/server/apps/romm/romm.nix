{ pkgs, lib, config, ... }:
let
  # Where my game files are stored on my NAS
  gamesDir = "/nas/tank/media/games/emulation/games";
  # Where my bios files are stored on my NAS. 
  biosDir = "/nas/tank/media/games/emulation/bios";
  # Where in the container RomM expects the game files to be stored. 
  rommRomLibrary = "/romm/library/roms";
  # Where in the container RomM expects the bios files to be stored. 
  rommBiosLibrary = "/romm/library/bios";
in
{
  imports = [
    # SOPS secret declarations for RomM and its database
    ./secrets/secrets_romm.nix
  ];

  # Ensure the romm docker network exists on this host
  systemd.services.docker-create-romm-network = {
    description = "Create romm docker bridge network";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Keep the unit "active (exited)" after success so units that depend on
      # it (the romm containers) see the dependency as satisfied.
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect romm-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create romm-network
    '';
  };

  # Make the auto-generated container units wait for the network to exist.
  systemd.services.docker-romm.after = [ "docker-create-romm-network.service" ];
  systemd.services.docker-romm.requires = [ "docker-create-romm-network.service" ];
  systemd.services.docker-romm-db.after = [ "docker-create-romm-network.service" ];
  systemd.services.docker-romm-db.requires = [ "docker-create-romm-network.service" ];

  virtualisation.oci-containers.containers.romm = {
    image = "rommapp/romm:4.8.1";
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
      "${gamesDir}/nds:${rommRomLibrary}/nds" # Nintendo DS
      "${gamesDir}/nes:${rommRomLibrary}/nes" # Nintendo Entertainment System
      "${gamesDir}/n64:${rommRomLibrary}/n64" # Nintendo 64
      "${gamesDir}/snes:${rommRomLibrary}/snes" # Super Nintendo Entertainment System
      "${gamesDir}/md:${rommRomLibrary}/genesis" # megadrive/genesis
      "${gamesDir}/gg:${rommRomLibrary}/gamegear" # game gear
      "${gamesDir}/gw:${rommRomLibrary}/g-and-w" # game and watch
      "${gamesDir}/ngpc:${rommRomLibrary}/neo-geo-pocket-color" # Neo Geo Pocket Color
      "${gamesDir}/sms:${rommRomLibrary}/sms" # Sega Master System

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
}