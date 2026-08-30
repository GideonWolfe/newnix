{ pkgs, ... }:
# Source-side config for offsite replication: soteria PULLS datasets from here.
#
# This creates a restricted `syncoid` user that soteria's syncoid authenticates
# as over SSH. It is NOT root — it only holds soteria's dedicated public key and
# is granted the minimum ZFS delegation needed to send snapshots. The actual
# `zfs allow` grant is applied manually per-dataset (see the header note below),
# so adding a dataset to the offsite set is a deliberate two-step action.
{
    # syncoid transport helpers, needed on the SOURCE too. soteria's syncoid
    # invokes these over SSH on mnemosyne; without them the sync runs
    # uncompressed + unbuffered (see the lzop/mbuffer warnings in soteria's
    # syncoid journal). lzop = on-wire compression, mbuffer = latency buffering.
    environment.systemPackages = with pkgs; [ lzop mbuffer pv ];

    users.users.syncoid = {
        isSystemUser = true;
        group = "syncoid";
        # syncoid runs `zfs send` over an interactive-ish SSH session, so the
        # account needs a real shell (nologin breaks the transport).
        shell = pkgs.bash;
        openssh.authorizedKeys.keys = [
            # soteria's dedicated syncoid pull key (private half is sops-managed
            # on soteria at hosts/soteria/zfs/secrets_syncoid.yaml).
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaW+sqTh+XTG4CF6XXmym5mtHVJPXy2T3gXTPPRbVmR syncoid@soteria"
        ];
    };
    users.groups.syncoid = {};

    # ZFS send delegation is applied by hand (not declarative) so it stays an
    # explicit, per-dataset decision. After deploying this module, run on
    # mnemosyne for each dataset added to the offsite set, e.g.:
    #
    #     sudo zfs allow syncoid send,snapshot,hold tank/media/games
    #
    # (start with tank/media/games for the first replication run).
}
