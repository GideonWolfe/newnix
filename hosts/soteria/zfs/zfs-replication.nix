{ config, pkgs, ... }:
# Offsite replication: soteria PULLS selected datasets from mnemosyne.
#
# Pull-model rationale: the backup box holds the credentials and initiates the
# connection, so a compromise of mnemosyne can't reach in and delete the
# offsite copies. soteria only needs outbound SSH to mnemosyne (over the WG
# tunnel).
#
# The pulled datasets land under tank/backups/* which are `readonly=on` and are
# owned entirely by syncoid -- never write to them directly. sanoid on soteria
# runs prune-only on these (autosnap=false); syncoid brings the snapshots over
# via --no-sync-snap.
#
# STAGED ROLLOUT: starting with a SINGLE dataset (tank/personal) to validate the
# whole path end-to-end before adding the rest.
{
    # syncoid transport helpers. Without these on BOTH ends syncoid falls back
    # to uncompressed, unbuffered transfers (it warns about missing lzop/mbuffer):
    #   - lzop:    on-the-wire compression (big win for compressible datasets)
    #   - mbuffer: buffering to smooth throughput over the high-latency WG tunnel
    #   - pv:      progress metering
    environment.systemPackages = with pkgs; [ lzop mbuffer pv ];

    # Private key syncoid uses to reach mnemosyne. sops-encrypted for soteria's
    # age key only; decrypts to a file owned by the syncoid service user.
    sops.secrets."syncoid/id_ed25519" = {
        sopsFile = ./secrets_syncoid.yaml;
        owner = config.services.syncoid.user;
        group = config.services.syncoid.group;
        mode = "0400";
    };

    services.syncoid = {
        enable = true;

        # Pull key (sops-managed, see secret above).
        sshKey = config.sops.secrets."syncoid/id_ed25519".path;

        # Flags applied to every command.
        commonArgs = [
            "--no-sync-snap"        # rely on sanoid's snapshots from the source
            "--sshoption=Port=2736"  # mnemosyne's non-standard SSH port
            # NOTE: no --source-bwlimit. Seeds run at full uplink speed; the
            # offsite link isn't shared with anything latency-sensitive, so
            # finishing the (large, one-time) seeds sooner is preferable. Add a
            # cap back here if seeds ever need to yield bandwidth.
        ];

        commands = {
            # FIRST DATASET: tank/media/games (~299G, a "keeper"). mnemosyne now
            # snapshots it via sanoid (media template), so --no-sync-snap has a
            # snapshot chain to work from. Source is the restricted `syncoid`
            # user on mnemosyne, reached over the WG tunnel. Nested under
            # backups/media/ to mirror the source layout for when tv/movies/etc
            # are added later.
            "syncoid@${config.custom.world.hosts.mnemosyne.ip}:tank/media/games" = {
                target = "tank/backups/media/games";
            };

            # tank/personal — the "personal" sanoid template on mnemosyne
            # (hourly/daily churn), already snapshotted there. High-value data,
            # so it goes offsite. Target mirrors the source path.
            "syncoid@${config.custom.world.hosts.mnemosyne.ip}:tank/personal" = {
                target = "tank/backups/personal";
            };

            # tank/media/music (~316G). Already snapshotted on mnemosyne via the
            # media sanoid template. Nested under backups/media/ alongside games.
            "syncoid@${config.custom.world.hosts.mnemosyne.ip}:tank/media/music" = {
                target = "tank/backups/media/music";
            };

            # tank/media/books (~68M). Already snapshotted on mnemosyne via the
            # media sanoid template. Nested under backups/media/.
            "syncoid@${config.custom.world.hosts.mnemosyne.ip}:tank/media/books" = {
                target = "tank/backups/media/books";
            };

            # tank/infra/services (~24G). Service config/state, snapshotted on
            # mnemosyne via the service_backups sanoid template.
            # NOTE: an empty tank/backups/infra/services placeholder exists from
            # early planning -- destroy it before the first seed (else syncoid
            # "cowardly refuses" to overwrite the existing target).
            "syncoid@${config.custom.world.hosts.mnemosyne.ip}:tank/infra/services" = {
                target = "tank/backups/infra/services";
            };

            # tank/infra/ai (~10G). AI model/prompt library, snapshotted on
            # mnemosyne via the service_backups sanoid template.
            "syncoid@${config.custom.world.hosts.mnemosyne.ip}:tank/infra/ai" = {
                target = "tank/backups/infra/ai";
            };
        };
    };

    # syncoid connects to mnemosyne over SSH; pin its host key so the first
    # unattended pull doesn't fail host verification (no TOFU prompt). mnemosyne's
    # sshd listens on 2736, and SSH looks up non-standard ports under the
    # bracketed "[host]:port" form, so that must be the known_hosts hostname.
    programs.ssh.knownHosts."mnemosyne-offsite" = {
        hostNames = [ "[${config.custom.world.hosts.mnemosyne.ip}]:2736" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjUMb0RfitORlVjcgffhsR+DruflDPsV1/D04k48xe6 root@mnemosyne";
    };
}

