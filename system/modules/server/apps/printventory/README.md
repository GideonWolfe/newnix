# Printventory

[Printventory](https://github.com/TechJeeper/Printventory) catalogs existing 3D
models in place. This module is imported by `vm-app1`; deploy that host normally,
then open <http://192.168.88.101:5000>.

## Storage and source-file protection

| Purpose | Host path | Container path | Access |
| --- | --- | --- | --- |
| NAS gear collection | `/nas/tank/personal/gear` | `/models` | **Read-only** |
| Database, tags, settings, thumbnails and preview cache | `/data/printventory/config` | `/root/.config/printventory` | Read-write |

The model mount is read-only at the filesystem boundary, not just an application
preference. Scanning and tagging do not move or rewrite originals. Printventory's
upload, rename, move, and file-deletion actions cannot modify this collection,
even though those actions may still appear in the UI. Removing a catalog entry
or changing tags can still modify the separate database.

Only the gear directory is exposed, not the entire NAS. The service requires the
local data disk and NFS mount before starting and refuses to start if the source
directory is missing. It never creates or changes permissions on NAS directories.
ZIP preview extraction uses the container's temporary storage, not the source
folder. Files must already be readable through NFS; no source permissions are
relaxed by this module.

## Scanning

- `STL_HOME=/models` scans recursively through the gear subdirectories on startup.
- Automatic rescans default to every **60 minutes**. Adjust the frequency and
  excluded folders under **Settings → STL Home**.
- STL and 3MF files, including supported models inside ZIP archives, are scanned
  by default. Enable additional formats such as OBJ and STEP under **Settings →
  File Types** if needed.
- The default scan file-size limit is **50 MB**. Raise it in Settings if larger
  models are missing; supported formats and the size limit determine coverage.
- The scan root and internal port are reapplied from the module on restart.
  Keep the root as `/models`; do not enter the host's NAS path in the UI.
- Thumbnail rendering uses CPU-based SwiftShader, capped at two CPUs and 4 GiB
  of container memory. Initial scans can take time on larger collections.

Tags and notes live in Printventory's database, not alongside the models. Back
up the application state separately from the NAS collection, using the app's
database backup feature or copying the config directory while the service is
stopped. No scheduled backup is configured by this module.

## Access and upgrades

The web UI and MCP endpoint have **no built-in authentication**. The port is
bound to the VM's LAN address, with no public DNS entry or Traefik route. Anyone
who can reach it can view models and modify the catalog; do not port-forward it
or expose it publicly without an authenticated reverse proxy.

The official image is pinned to version **2.2.15** and its digest. Update both
together when upgrading. The upstream image runs as root and does not implement
`PUID`/`PGID`; its Linux capabilities are dropped, privilege escalation is blocked,
and the NAS users group is supplied for group-readable files. Persistent state
is root-owned beneath a private parent directory on the VM.
