{ pkgs, lib, config, ... }:

let
  # Host-side path that is bind-mounted into the container as /app
  soulsyncConfigDir = "/data/soulsync/config";
in
{

  sops.secrets."navidrome/username" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };
  sops.secrets."navidrome/password" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };

  # Define a SOPS template for the SoulSync config.json
  sops.templates."soulsync-config.json".content = builtins.toJSON {
    active_media_server = "jellyfin";
    spotify = {
      client_id = "SpotifyClientID";
      client_secret = "SpotifyClientSecret";
      redirect_uri = "http://127.0.0.1:8888/callback";
    };
    tidal = {
      client_id = "TidalClientID";
      client_secret = "TidalClientSecret";
      redirect_uri = "http://127.0.0.1:8889/tidal/callback";
    };
    plex = {
      base_url = "http://192.168.86.36:32400";
      token = "PLEX_API_TOKEN";
      auto_detect = true;
    };
    jellyfin = {
      base_url = "http://localhost:8096";
      api_key = "JELLYFIN_API_KEY";
      auto_detect = true;
    };
    navidrome = {
      base_url = "https://nd.gideonwolfe.xyz";
      username = "${config.sops.placeholder."navidrome/username"}";
      password = "${config.sops.placeholder."navidrome/password"}";
      auto_detect = true;
    };
    soulseek = {
      slskd_url = "http://slskd:5030";
      api_key = "${config.sops.placeholder."slskd/apikey"}";
      download_path = "/app/downloads";
      transfer_path = "/app/Transfer";
      search_timeout = 60;
      search_timeout_buffer = 15;
    };
    logging = {
      path = "logs/app.log";
      level = "INFO";
    };
    database = {
      path = "database/music_library.db";
      max_workers = 5;
    };
    metadata_enhancement = {
      enabled = true;
      embed_album_art = true;
    };
    file_organization = {
      enabled = true;
      _template_variables = "Available: $artist, $albumartist, $album, $title, $track, $year, $playlist";
      templates = {
        album_path = "$albumartist/$albumartist - $album/$track - $title";
        single_path = "$artist/$artist - $title/$title";
        compilation_path = "Compilations/$album/$track - $artist - $title";
        playlist_path = "$playlist/$artist - $title";
      };
    };
    playlist_sync = {
      create_backup = true;
    };
    listenbrainz = {
      token = "LISTENBRAINZ_TOKEN";
    };
  };

  ##########
  # Config #
  ##########
  # Seed slskd.yml on the host before the container starts
  systemd.services.soulsync-seed-config = {
    description = "Seed SoulSync config.json";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-soulsync-webui.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      set -e
      mkdir -p ${soulsyncConfigDir}
      if [ ! -f ${soulsyncConfigDir}/config.json ]; then
        install -m 600 ${config.sops.templates."soulsync-config.json".path} ${soulsyncConfigDir}/config.json
      fi
      # Ensure the config remains readable by the host user and container
      chown -R 1000:100 ${soulsyncConfigDir}
      chmod 0640 ${soulsyncConfigDir}/config.json
    '';
  };

  # Ensure the container waits for its config
  systemd.services.docker-soulsync-webui = {
    requires = [ "soulsync-seed-config.service" ];
    after = [ "soulsync-seed-config.service" ];
  };
}
