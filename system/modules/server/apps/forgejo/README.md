# Forgejo

Follow [RUNBOOK.md](RUNBOOK.md) for the deployment steps. This configuration uses
the official **15.0.6-rootless** image, pinned by digest, on **vm-app2**.

- Web: <http://192.168.88.104:3030>
- Git SSH: **git** on port **2222**, handled inside the container.
- VM administration: existing **gideon** login on port **2736**, unchanged.
- LAN/VPN-only. No public DNS, Traefik route, runners or Actions are configured.

Nix manages the container, mounts, security defaults and backups. Use Forgejo's
normal setup wizard once, then add your account's SSH keys and repository mirrors
in the UI. No custom account bootstrap, key reconciler, host Git account, SSH
wrapper or global tmpfiles override is required.

The image/module defaults handle SQLite selection, HTTP and embedded SSH listeners,
mirror intervals, container startup and timeouts. Overrides are limited to the
storage layout, published addresses, privacy/security choices and backup handling.

## Storage and permissions

| Host path | Container path | Contents |
| --- | --- | --- |
| `/data/forgejo` | `/var/lib/gitea` | Local configuration, SQLite, secrets, SSH host keys, attachments and indexes |
| `/nas/tank/personal/code` | `/code` | NAS `repositories/` and `lfs/` directories |

The image retains its upstream `gitea` directory names. Its configuration is
`/var/lib/gitea/custom/conf/app.ini`; SQLite is explicitly set to
`/var/lib/gitea/data/forgejo.db`. Both stay on the VM's ext4 disk.

The container runs as **1000:100**, matching the NAS exports already configured
with `all_squash,anonuid=1000,anongid=100`. Use that ownership for the NAS code and
backup directories. **Do not change the shared exports or use the earlier 2042
NAS ownership instructions.** The only local preparation creates the private
state directory; the image manages its contents. Mount dependencies prevent
starting against unmounted storage.

“Rootless image” means Forgejo runs without root inside the existing Docker
daemon. It does not enable a rootless Docker daemon or remap UIDs. The container
has no Docker socket, extra capabilities or access to the rest of the NAS.

**Squashed NFS is shared-trust storage.** All permitted clients reach these
exports as the same NAS identity. Directory modes do not isolate their users
from one another, and direct NFS access bypasses Forgejo's repository permissions.
Keep the exports limited to trusted hosts. Restic encrypts backups but cannot
stop another permitted NFS client deleting them; offsite snapshots matter.

Repositories are ordinary bare Git, not working folders. Develop in separate
clones, not in the NAS backing tree. LFS objects are separate from Git pointers;
submodules need their own mirrors. Keep the code folder inside `tank/personal`
and backups inside `tank/infra/services`, not new child datasets, so the existing
Sanoid and soteria replication policies cover both.

## SSH, account setup and mirroring

Complete the installation wizard promptly on the trusted LAN. Create admin
`gideon` there; the wizard persists its install lock and secrets. Registration
is disabled and sign-in is required afterward. Declared environment settings are
reapplied at container startup; account data and keys remain in the database.

Add the existing primary and backup YubiKey **public keys** through account
settings. The workstation's `forgejo` SSH alias offers both existing credential
handles and connects as `git` on port 2222. Use `forgejo:gideon/project.git`, or
`ssh://git@192.168.88.104:2222/gideon/project.git`. No VM authorized-key changes or
private key copies are needed. Normal touch/PIN requirements and disabled agent
forwarding remain; GPG commit signing is separate.

Create **pull mirrors** through New Migration, selecting “This repository will
be a mirror” at creation. Use the upstream interval or adjust it in the UI. Public Git repositories
usually need no credential; private sources need appropriately scoped read tokens.
Unattended mirrors should not depend on your touch-required YubiKey.

Removing environment overrides does not reset settings already saved by an earlier
installation. Existing mirror schedules remain unchanged unless edited in the UI.

Mirroring follows deletions and force-pushes; it is not immutable archival storage.
It does not auto-discover stars/new repositories or continuously copy cloud issue,
PR and release metadata. Verify LFS explicitly, using HTTPS mirrors for LFS.
To become authoritative later, convert a pull mirror to an ordinary repository
before pushing to it. Optional push mirrors back to the cloud can overwrite
destination changes; do not treat them as two-way synchronization.

## Backups and recovery

On the NixOS Restic module's default **daily** schedule, `restic-backups-forgejo` stops
`docker-forgejo`, including its web, mirror and SSH processes. It confirms the
container is stopped, then saves local state, NAS repositories and NAS LFS in
**one Restic snapshot**. It records the pinned image in `container-image.txt`.
Only logs are excluded. No live SQLite copy or separate dump timer is used.

Backups run as `gideon` (1000:100), using the SOPS `forgejo/restic_password` secret,
and write to `/nas/tank/infra/services/forgejo/restic_backup`. Retention is 7 daily,
4 weekly and 6 monthly snapshots. The container restarts on success or failure;
administrative SSH stays available, and missed timers catch up after downtime.
Use systemd to control the container, not ad-hoc
`docker start/run` commands that bypass backup ordering.

For full recovery, disable the backup timer, finish any running backup, then stop
the container. Restore **all three trees from the same snapshot**, using a fresh
staging directory rather than overlaying old data. Preserve 1000:100 ownership,
the configuration, application secrets and SSH host keys. Begin with the recorded
image, verify a login, push/clone and LFS download, then re-enable backups.
Recreating a container does not erase mounted data. Downgrading a NixOS generation
does not undo a database migration; an application downgrade needs a matching backup.

If a previous native installation actually contains data, back it up before any
conversion. Its generated configuration and hooks can contain host-specific Nix
paths, and its local ownership differs. Do not blindly reuse it as container state.
No data migration, NAS permission changes or deployment are performed by this module.

References: [Docker/NFS](https://forgejo.org/docs/v15.0/admin/installation/docker/),
[mirrors](https://forgejo.org/docs/v15.0/user/repo-mirror/),
[backup consistency](https://forgejo.org/docs/v15.0/admin/upgrade/#backup).