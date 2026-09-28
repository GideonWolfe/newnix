# Proxmox cluster: HA design & operations

Documents the high-availability design deployed on the Proxmox cluster after the
September 2026 hardware work, plus the operational procedures and gotchas learned
while getting there. This reflects the **live, deployed state**.

## Why HA exists here

The original problem: `vm-app1` (immich + postgres + docker) was dying around
04:00 most nights. Root cause was the **host kernel OOM-killer reaping the KVM
process** on pve2 — the node was memory-oversubscribed, and an overnight
replication window pushed it over the edge. `onboot` did not bring the guest
back, because it only starts guests when the *node* boots, not when a running
guest is killed while the node stays up.

The fix had two parts: **add real RAM headroom** (pve2 and pve3 both upgraded to
32 GiB) and **add proper runtime recovery** (Proxmox HA), so any single node
failing relocates its guests automatically.

## Storage model (the key constraint)

There is **no shared storage**. Each node has a local `datapool` ZFS SSD, and VM
disks are replicated node-to-node on a schedule. Consequences:

- A VM can only fail over to a node that already holds a **replicated copy** of
  its disks, and that has the **RAM** to start it.
- Replicating every VM to every node would hammer the consumer SSDs, so each VM
  has exactly **one primary + one failover node**.
- Failover uses the last replicated snapshot, so **writes since the last sync can
  be lost** on failover — acceptable for these workloads at a 15-minute cadence.

## Failover layout

`pvetower` is AI-only (48 GiB guest, excluded from HA). `pvenet` has no `datapool`
yet, so it cannot be a failover target.

| VM  | name           | memory | balloon floor | primary | failover |
|-----|----------------|--------|---------------|---------|----------|
| 101 | vm-app1        | 16 GiB | 10 GiB        | pve2    | pve3     |
| 104 | vm-app2        | 8 GiB  | 4 GiB         | pve3    | pve2     |
| 100 | vm-ingress     | 2 GiB  | 0.75 GiB      | pve2    | pve3     |
| 105 | home-assistant | 4 GiB  | 2 GiB         | pve2    | pve3     |
| 103 | vm-test        | 4 GiB  | 2 GiB         | pve3    | pve2     |
| 102 | vm-media       | 8 GiB  | 4 GiB         | pve1    | pve2     |
| 106 | vm-ai          | 48 GiB | 0 (pinned)    | pvetower| none     |

pve2 and pve3 are both 32 GiB. Worst-case single-node failure fits within a
node's RAM once the failed-over guests balloon down to their floors.

### Why balloon floors

- `memory` is the normal running size; `balloon` is the floor the host can shrink
  a guest to **only under host memory pressure**. Steady state runs at full
  `memory`.
- During a failover the target node is briefly overcommitted; ballooning lets the
  host squeeze guests toward their floors so **everything stays running (degraded)
  instead of one guest being OOM-killed**. On repair/migrate-back they re-inflate.
- Floors are set above each app's working set (e.g. app1's postgres/immich needs
  ≥10 GiB) so the degraded state is survivable, not thrashing.

`vm-app1` deliberately does **not** use `balloon = 0` any more. The original OOM
came from the *host* being oversubscribed, not from ballooning; with 32 GiB and a
10 GiB floor, the balloon only acts during an actual failover.

### CPU compatibility

The cluster is mixed Intel (pve1/pve3) and AMD (pve2/pvetower). HA failover is a
**cold restart**, so `cpu = host` is fine across vendors. Only *live* migration is
blocked across CPU vendors — which is why any manual moves here are offline.

## How HA is wired

Each HA VM needs three things working together:

1. **`hastate = "started"`** — set declaratively in the terranix files
   (`hosts/proxmox/terranix/vm-*.nix`), applied via OpenTofu.
2. **A replication job** to its failover node — managed in Proxmox
   (`/etc/pve/replication.cfg`), not in terranix.
3. **A node-affinity rule** — `ha-manager` CLI only; the Telmate provider
   (`3.0.2-rc07`) has no resource for HA rules.

### Node-affinity rules

Priorities mean "prefer primary, allow failover to secondary". They are **not
strict** — a strict rule would stop the VM rather than fail it over when the
preferred node is down.

```sh
ha-manager rules add node-affinity aff-app1    --resources vm:101 --nodes 'pve2:2,pve3:1'
ha-manager rules add node-affinity aff-app2    --resources vm:104 --nodes 'pve3:2,pve2:1'
ha-manager rules add node-affinity aff-ha      --resources vm:105 --nodes 'pve2:2,pve3:1'
ha-manager rules add node-affinity aff-test    --resources vm:103 --nodes 'pve3:2,pve2:1'
ha-manager rules add node-affinity aff-media   --resources vm:102 --nodes 'pve1:2,pve2:1'
ha-manager rules add node-affinity aff-ingress --resources vm:100 --nodes 'pve2:2,pve3:1'
```

Inspect with `ha-manager rules list`, `ha-manager status`, `ha-manager config`.

### Replication schedule

All jobs are rate-limited to 30 MB/s to protect the consumer SSDs, and their
schedules are **staggered** so no two jobs run on the same minute (same 15-minute
cadence, offset across the hour).

| Job   | Source→Target | Schedule        |
|-------|---------------|-----------------|
| 105-2 | pve2→pve3     | `0,15,30,45`    |
| 100-2 | pve2→pve3     | `1,16,31,46`    |
| 101-2 | pve2→pve3     | `3,18,33,48`    |
| 102-2 | pve1→pve2     | `6,21,36,51`    |
| 104-2 | pve3→pve2     | `9,24,39,54`    |
| 103-2 | pve3→pve2     | `12,27,42,57`   |

## Operational procedures

### Managing replication

```sh
# create a job (run on the SOURCE node)
pvesr create-local-job <vmid>-<n> <target> --schedule '3,18,33,48' --rate 30

# change schedule/rate in place (a job's SOURCE auto-follows the guest)
pvesr update <jobid> --schedule '0,15,30,45' --rate 30

pvesr run <jobid>              # force a run now
pvesr status                  # PER-SOURCE-NODE only (not cluster-wide)
cat /etc/pve/replication.cfg  # all job definitions (cluster file)
pvesh get /cluster/replication # all jobs via API; or GUI Datacenter → Replication
```

- Only delete/recreate a job when its **target** is wrong; the source follows the
  guest automatically. Changing the target forces a full initial re-sync.
- **Initial full syncs**: run one at a time, waiting for `/proc/pressure/io`
  `avg10` to drop to single digits between them. The scheduler won't overlap a
  job with itself, but different jobs at the same tick will contend for the disk.
- A stuck job that references a missing dataset can be removed by deleting its
  stanza directly from `/etc/pve/replication.cfg` (cluster-wide file).

### Node maintenance

```sh
ha-manager crm-command node-maintenance enable <node>   # migrate HA guests off
# shut down any remaining guests, then on the node:
shutdown -h now
# ... hardware work ...
ha-manager crm-command node-maintenance disable <node>
pvecm status                                            # confirm Quorate
```

### SSD TRIM (consumer drives)

Consumer SATA SSDs (Crucial BX500 here) stall after large deletes if untrimmed:
IO pressure stays high (`/proc/pressure/io some avg10` 60%+) with near-zero
throughput, and ZFS commands time out.

```sh
zpool status -t datapool          # look for (untrimmed) vs (100% trimmed)
zpool trim datapool               # per node — pools are local
zpool set autotrim=on datapool    # durable; prevents recurrence
```

- TRIM after any large delete (destroying VMs/snapshots).
- Don't start a big replication sync on a pool mid-trim — let it finish first.
- Keep pools under ~80% full.

### Keeping the pool lean

Migrations renumber disks and leave the old ones as `unused*`; snapshots with
saved RAM leave `vm-<id>-state-*` volumes behind. These bloat every
migration/replication.

```sh
# after any migration, check for orphan disks:
qm config <vmid> | grep unused
qm disk unlink <vmid> --idlist unusedN     # detaches AND destroys the zvol

# periodic audit:
zfs list -t volume -o name | grep state    # orphan state volumes
zfs list -t snapshot -o name,creation | grep -v __replicate_
```

- Safe to destroy: `vm-<id>-state-*` volumes and orphaned `disk-N` from deleted
  VMs. **Never** destroy an active `disk-N` (check `qm config` first), and never
  hand-delete `__replicate_*` snapshots (owned by the replication system).
- Prefer NAS vzdump/PBS backups over long-lived VM snapshots for rollback points —
  snapshots pin blocks on the expensive local SSD.
- A timed-out `zfs destroy` often still completes in the background; re-check
  `zfs list` before retrying.

### Recovering an accidentally-deleted VM

If a VM's config is gone but its disks survive on `datapool`, a full restore isn't
needed. Reattaching the surviving disks keeps the freshest data:

```sh
qm create <vmid> --name <name> --memory <M> --cores <C> --cpu host \
  --bios seabios --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr0 \
  --ostype l26 --agent 1
qm set <vmid> --virtio0 datapool:vm-<vmid>-disk-0,discard=on,serial=rootdisk
qm set <vmid> --virtio1 datapool:vm-<vmid>-disk-1,discard=on,serial=data
qm set <vmid> --boot order=virtio0
qm start <vmid>
```

Or restore from a vzdump backup (self-contained, possibly older):
`qmrestore /mnt/pve/<storage>/dump/vzdump-qemu-<vmid>-<date>.vma.zst <vmid> --storage datapool`

## Terraform / OpenTofu notes

State lives on the NAS (`/nas/tank/infra/terraform/proxmox/terraform.tfstate`,
NFS-mounted, ZFS-snapshotted). Provider is Telmate/proxmox `3.0.2-rc07`.

**Review gate — never apply a plan that shows** `destroy and then create`,
`must be replaced`, a disk recreate/detach/resize, or a MAC change. Only
`~ update in-place` with attribute/metadata diffs is safe.

**Identify disks by `serial`** (`rootdisk`/`data`), not disk number — serials
survive migration renumbering; `disk-N` names don't.

### Importing an existing VM

```sh
tofu import proxmox_vm_qemu.<name> <node>/qemu/<vmid>
tofu plan   # iterate the .nix until "No changes"
```

ForceNew triggers seen on import, fixed via `lifecycle.ignore_changes` (see
`vm-home-assistant.nix`):

- **`full_clone`** — schema default `true` vs imported state `false` forces a
  replace; ignore `full_clone` (and `clone`) on imported VMs.
- **`efidisk`** block — import doesn't populate it, so re-declaring forces a
  replace; ignore `efidisk`.
- **Boot-order / cdrom removal** — `invalid bootorder: device 'ide2' does not
  exist` means Terraform tried to drop the empty cdrom while the boot order still
  referenced it. Pin `boot = "order=scsi0"` so removal and boot order stay
  consistent.

"Resource already managed by OpenTofu": the state address already exists. Check
`tofu state show <addr>`; if it already points at the right `<node>/qemu/<vmid>`,
skip the import and just plan. If stale, `tofu state rm <addr>` (forgets it from
TF, does **not** delete the VM) then re-import.

## Hardware-swap gotchas

Moving SSDs into different hardware (or replacing a node) triggers these:

- **SSH host key changed:** `ssh-keygen -R <host>` then reconnect.
- **NIC renamed:** a new NIC has a new MAC, so a name pinned to the old MAC (e.g.
  `bridge-ports nic0`) no longer matches and the kernel falls back to `eno1`.
  Symptom: `bridge link` is empty, `vmbr0` has its IP but no uplink, nothing
  pings. Fix `bridge-ports` in `/etc/network/interfaces` to the real NIC
  (`ip -br l`), then `ifreload -a`. PVE networking here is set at install time
  only (not from this repo), so the live edit is the durable fix — remove any
  stale `nic0` `.link`/udev pin if present.
- **RAM upgrade:** brand/model need not match, but DDR gen, form factor
  (SO-DIMM), ECC/voltage must. Check with `dmidecode --type 16` (slots/max) and
  `--type 17` (per-slot). Power off and unplug before installing; if it won't
  POST, bench-test one stick at a time rather than re-racking between tests.

## Node / RAM map

| Node     | IP            | CPU              | RAM    | Role                    |
|----------|---------------|------------------|--------|-------------------------|
| pve1     | 192.168.88.8  | Intel i5-6500T   | 16 GiB | vm-media primary        |
| pve2     | 192.168.88.9  | AMD              | 32 GiB | app1/ingress/HA primary |
| pve3     | 192.168.88.10 | Intel i5-6500T   | 32 GiB | app2/test primary       |
| pvenet   | 192.168.88.7  | —                | 16 GiB | no datapool (not HA)    |
| pvetower | 192.168.88.11 | AMD Ryzen 9 7900X| 62 GiB | vm-ai only              |

## Known follow-ups

- `pvenet` cannot host failover VMs until it has a `datapool` (a single-disk
  install like pvetower is under consideration).
- Consider pinning each VM's `macaddr` in its terranix network block so a future
  rebuild keeps the same MAC (matches the disk-`serial` robustness pattern).

References: [Proxmox HA documentation](https://pve.proxmox.com/pve-docs/chapter-ha-manager.html),
[Telmate VM resource docs](https://github.com/Telmate/terraform-provider-proxmox/blob/v3.0.2-rc07/docs/resources/vm_qemu.md).
