# Youtarr

[Youtarr](https://youtarr.com/) runs on `vm-app2` alongside the other app services.
The UI is available at <http://192.168.88.104:3087> after deploying that VM.
It is LAN-only, with built-in authentication enabled; no DNS or Traefik changes
are needed.

## Storage

| Purpose | VM path | Container path |
| --- | --- | --- |
| Media on mnemosyne | `/nas/tank/media/youtube` | `/usr/src/app/data` |
| Configuration, credentials and download archive | `/data/youtarr/config` | `/app/config` |
| Job state | `/data/youtarr/jobs` | `/app/jobs` |
| Thumbnails | `/data/youtarr/images` | `/app/server/images` |
| MariaDB | `/data/youtarr/database` | `/var/lib/mysql` |

The media directory is `/tank/media/youtube` on mnemosyne. The existing NFS
module supplies the mount; Youtarr waits for it and the local data disk before
starting. It creates the media directory as UID 1000 / GID 100 if missing and
checks write access without changing existing media ownership. The NAS parent
directory must allow that user to create it.

Keep Youtarr's **Use External Temporary Directory** setting disabled (the
upstream default), so staging and final media stay on the same NFS filesystem.

## Initial setup

1. Create and SOPS-encrypt the secrets described below, then include the new
   files when deploying `vm-app2` from this checkout. No NAS rebuild is required.
2. Open the LAN UI and log in with the preset username and password from SOPS;
   these bypass the setup-token wizard.
3. Configure channels, download schedules, and optional Jellyfin integration in
   the UI. Jellyfin must have a library pointing at the same NAS media directory.

The SOPS file referenced in [secrets/secrets_youtarr.nix](secrets/secrets_youtarr.nix)
needs this structure, with a different strong password for each placeholder:

```yaml
youtarr-db:
  password: "APP_DATABASE_PASSWORD"
  root_password: "SEPARATE_DATABASE_ROOT_PASSWORD"
youtarr:
   username: "ADMIN_USERNAME"
   password: "SEPARATE_ADMIN_PASSWORD"
  restic_password: "SEPARATE_BACKUP_ENCRYPTION_PASSWORD"
```

The encryption rule includes `vm-app2` and the existing GPG recipient. The
`youtarr/username` and `youtarr/password` secrets populate `AUTH_PRESET_USERNAME`
and `AUTH_PRESET_PASSWORD`. Use a 1–32 character username without leading/trailing
spaces and an 8–64 character password; keep both values on a single line.
Youtarr reapplies these credentials on every start, overriding UI changes.
Deploying changed credentials restarts the app through the SOPS template.

The app uses a dedicated database user, not root. MariaDB passwords seed a
fresh database; rotating them later also requires updating the database accounts.

## Backups

The daily `restic-backups-youtarr` job saves config (including the download
archive), jobs, thumbnails, and a transactional MariaDB SQL dump to the NAS at
`/nas/tank/infra/services/youtarr/restic_backup`. Retention matches the other
apps: 7 daily, 4 weekly, and 6 monthly snapshots. It runs as `gideon`, which
already has Docker access, to avoid NFS root-squash permission issues.

This is a live backup. For an exactly matching database/archive snapshot, stop
the Youtarr app (leave MariaDB running) before triggering a manual backup.

Raw live database files and NAS media are not included. On restore, stop
Youtarr, restore the local app directories, import the saved SQL dump into the
running MariaDB container, then restart Youtarr. Preserve the encrypted secrets
alongside backups, and never discard the download archive when restoring.