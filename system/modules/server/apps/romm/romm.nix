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
  virtualisation.oci-containers.containers.romm = {
    image = "rommapp/romm:4.6.1";
    ports = [ "${builtins.toString config.custom.world.services.romm.port}:8080" ];
    autoStart = true;
    # https://docs.romm.app/4.5.0/Getting-Started/Environment-Variables/
    environment = {
      PUID = "1000";
      PGID = "100";
      DB_HOST = "romm-db";
      DB_NAME = "romm";
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
    extraOptions = [ "--network=romm-network" ];
    dependsOn = [ "romm-db" ];
    environmentFiles = [ config.sops.secrets."romm/env".path ];
  };

  virtualisation.oci-containers.containers.romm-db = {
    image = "mariadb:latest";
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      MARIADB_DATABASE = "romm";
    };
    volumes = [
      "/data/romm/romm_database:/var/lib/mysql"
    ];
    # TODO ensure this is actually created
    extraOptions = [ "--network=romm-network" ];
    environmentFiles = [ config.sops.secrets."romm-db/env".path ];
  };
}