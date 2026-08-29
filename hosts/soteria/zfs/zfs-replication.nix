{ ... }:
# Offsite replication: soteria PULLS selected datasets from mnemosyne.
#
# Pull-model rationale: the backup box holds the credentials and initiates the
# connection, so a compromise of mnemosyne can't reach in and delete the
# offsite copies. soteria only needs outbound SSH to mnemosyne.
#
# The pulled datasets land under tank/backups/* which should be `readonly=on`
# and are owned entirely by syncoid -- never write to them directly. sanoid on
# soteria runs prune-only on these (autosnap=false); syncoid brings the
# snapshots over via --no-sync-snap.
{
    services.syncoid = {
        enable = true;

        # Dedicated SSH key for pulling from mnemosyne (sops-managed).
        # TODO: provision the key + matching authorized_keys entry on mnemosyne
        #sshKey = "/etc/syncoid/id_ed25519";

        # Common flags applied to every command below.
        commonArgs = [
            "--no-sync-snap" # rely on sanoid's snapshots from the source
        ];

        # One entry per dataset we want offsite. Only replicate what genuinely
        # needs an offsite copy (personal, service/vm backups, irreplaceable
        # media) -- skip re-downloadable bulk media to save space.
        # TODO: finalize the source list + SSH target (user@host:port 2736)
        #commands = {
        #    "root@mnemosyne:tank/personal" = {
        #        target = "tank/backups/personal";
        #    };
        #    "root@mnemosyne:tank/infra/services" = {
        #        target = "tank/backups/infra/services";
        #    };
        #    "root@mnemosyne:tank/infra/vms/backups" = {
        #        target = "tank/backups/infra/vms/backups";
        #    };
        #};
    };
}
