# Companion to dawarich_backup.nix: instead of backing up Dawarich's
# application state, this pulls the *raw points* out of the API and writes one
# GPX file per day to the NAS (Dawarich, unlike Nextcloud, won't auto-export a
# daily GPX). Files land at:
#
#   /nas/tank/personal/gps-history/<YYYY>/<YYYY-MM-DD>.gpx
#
# It uses the personal API key from the shared dawarich secrets file. Day
# boundaries and GPX <time> values are UTC so the output is deterministic.
#
# A high-water mark (.last_export) tracks the last day fully exported so we
# don't re-hammer the API for historical days. The most recent `refreshDays`
# are always re-fetched to pick up points that arrived late.
{ pkgs, config, lib, ... }:
let
  svc = config.custom.world.services.dawarich;

  outDir  = "/nas/tank/personal/gps-history";
  apiBase = "http://127.0.0.1:${toString svc.port}";

  # Earliest day to back up. Bump this to when your tracking actually began to
  # avoid fetching a long tail of empty days on the first run.
  startDate   = "2024-08-01";
  refreshDays = 3;    # always re-export the last N days (late-arriving points)
  perPage     = 1000; # page size for the paginated /api/v1/points endpoint

  exporter = pkgs.writeShellApplication {
    name = "dawarich-gpx-export";
    runtimeInputs = [ pkgs.curl pkgs.jq pkgs.coreutils ];
    text = ''
      OUT_DIR="${outDir}"
      BASE="${apiBase}"
      START_DATE="${startDate}"
      REFRESH_DAYS=${toString refreshDays}
      PER_PAGE=${toString perPage}
      KEY_FILE="${config.sops.secrets."dawarich/api_key".path}"
      STATE_FILE="$OUT_DIR/.last_export"

      # Keep the API key out of argv/logs by feeding it to curl via a 0600
      # config file rather than a command-line --data-urlencode.
      KEY="$(cat "$KEY_FILE")"
      CURL_CONF="$(mktemp)"
      chmod 600 "$CURL_CONF"
      printf 'data-urlencode = "api_key=%s"\n' "$KEY" > "$CURL_CONF"
      trap 'rm -f "$CURL_CONF"' EXIT

      mkdir -p "$OUT_DIR"

      today="$(date -u +%Y-%m-%d)"
      end_day="$(date -u -d "$today - 1 day" +%Y-%m-%d)"   # last full day

      # Where to resume from: refreshDays before the previous high-water mark,
      # clamped to START_DATE. New days beyond the mark are picked up because
      # the loop always runs through to end_day.
      if [[ -f "$STATE_FILE" ]]; then
        last="$(cat "$STATE_FILE")"
        start="$(date -u -d "$last - $((REFRESH_DAYS - 1)) day" +%Y-%m-%d)"
      else
        last=""
        start="$START_DATE"
      fi
      if [[ "$start" < "$START_DATE" ]]; then
        start="$START_DATE"
      fi

      high_water="$last"
      failed=0
      day="$start"
      while [[ "$day" < "$end_day" || "$day" == "$end_day" ]]; do
        next="$(date -u -d "$day + 1 day" +%Y-%m-%d)"
        start_at="''${day}T00:00:00Z"
        end_at="''${next}T00:00:00Z"

        # Pull every page for the day into a scratch dir, stopping once a page
        # comes back shorter than PER_PAGE.
        pagedir="$(mktemp -d)"
        page=1
        ok=1
        while :; do
          out="$pagedir/$(printf '%05d' "$page").json"
          # Retry transient failures (500s from Rails/statement timeouts on
          # heavy days, connection resets) with backoff before giving up. Cap
          # each attempt so a hung request can't stall the whole run.
          if ! curl -fsS -G "$BASE/api/v1/points" -K "$CURL_CONF" \
                --retry 5 --retry-delay 10 --retry-all-errors --max-time 300 \
                --data-urlencode "start_at=$start_at" \
                --data-urlencode "end_at=$end_at" \
                --data-urlencode "order=asc" \
                --data-urlencode "per_page=$PER_PAGE" \
                --data-urlencode "page=$page" \
                -o "$out"; then
            echo "warn: fetch failed for $day (page $page)" >&2
            ok=0
            break
          fi
          n="$(jq 'length' "$out")"
          if [[ "$n" -lt "$PER_PAGE" ]]; then
            break
          fi
          page=$((page + 1))
        done

        if [[ "$ok" -ne 1 ]]; then
          rm -rf "$pagedir"
          failed=1
          break   # stop so the high-water mark stays contiguous; retry next run
        fi

        points="$(jq -s 'add // []' "$pagedir"/*.json)"
        count="$(printf '%s' "$points" | jq 'length')"
        rm -rf "$pagedir"

        # Only write a file for days that actually have points, so historical
        # empty days don't clutter the NAS.
        if [[ "$count" -gt 0 ]]; then
          year="''${day%%-*}"
          dir="$OUT_DIR/$year"
          file="$dir/$day.gpx"
          mkdir -p "$dir"
          {
            echo '<?xml version="1.0" encoding="UTF-8"?>'
            echo '<gpx version="1.1" creator="dawarich-gpx-export" xmlns="http://www.topografix.com/GPX/1/1">'
            echo "  <trk><name>$day</name><trkseg>"
            printf '%s' "$points" | jq -r '
              .[]
              | "    <trkpt lat=\"\(.latitude)\" lon=\"\(.longitude)\">"
                + (if .altitude != null then "<ele>\(.altitude)</ele>" else "" end)
                + "<time>\(.timestamp | todate)</time></trkpt>"
            '
            echo '  </trkseg></trk>'
            echo '</gpx>'
          } > "$file.tmp"
          mv -f "$file.tmp" "$file"
          echo "exported $day ($count points) -> $file"
        fi

        high_water="$day"
        day="$next"
      done

      # Advance the high-water mark only forward, and only for a clean run.
      if [[ -n "$high_water" ]]; then
        if [[ ! -f "$STATE_FILE" || "$high_water" > "$(cat "$STATE_FILE")" ]]; then
          echo "$high_water" > "$STATE_FILE"
        fi
      fi

      exit "$failed"
    '';
  };
in
{
  systemd.services.dawarich-gpx-export = {
    description = "Export Dawarich points to daily GPX files on the NAS";
    after    = [ "network-online.target" "docker-dawarich-app.service" ];
    wants    = [ "network-online.target" ];

    # Pull in (and order after) the NFS automount for the output path.
    unitConfig.RequiresMountsFor = outDir;

    serviceConfig = {
      Type      = "oneshot";
      ExecStart = lib.getExe exporter;
    };
  };

  systemd.timers.dawarich-gpx-export = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
