# Soteria — Offsite NAS Setup Guide

Living document for standing up **soteria**, the offsite backup NAS (UGREEN
DXP2800). Two workloads:

1. **ZFS replication target** — soteria *pulls* select datasets from
   mnemosyne's `tank` (pull model: the backup box holds the creds, so a
   compromise of mnemosyne can't reach in and delete offsite copies).
2. **Proxmox Backup Server (PBS) storage backend** — a separate PBS instance
   next to soteria stores its datastore on soteria over a scoped NFS export.

Connectivity is over the existing hub-and-spoke WireGuard (MikroTik hub at
home). soteria is a WG *client* — it dials out, nothing inbound is opened at
the remote site. The local Proxmox cluster reaches the remote PBS **without**
running WireGuard themselves, by routing through the home hub and soteria (see
Phase 9).

> Status legend: ☐ not started · ◐ in progress · ☑ done

> **PROGRESS (2026-08-29).** Phases 0–7 are ☑ **done**: soteria is installed on
> the eMMC, reachable only over WireGuard, ZFS mirror `tank` is up with datasets
> created, monitoring agent is live in home Grafana. Phase 8 is ◐ **in
> progress** — the first replication seed (`tank/media/games`, ~299G) is
> transferring over the throttled tunnel (~2 days). RESUME HERE when the seed
> completes: re-arm the games timer, then roll out the remaining datasets.
> Phases 9–10 (PBS routing + offsite compute) are ☐ not started.
>
> A condensed "what we actually did" record (for Obsidian) lives in
> `hosts/soteria/build-record.md`. This file keeps the forward-looking plan.

---

## Topology at a glance

```
  HOME SITE                          INTERNET            OFFSITE SITE
 ┌───────────────────────┐                            ┌───────────────────────┐
 │ Proxmox cluster        │                            │ soteria (NixOS)        │
 │ 192.168.88.x  (Debian) │                            │  LAN: 10.2.0.66        │
 │        │               │        WireGuard           │  wg0: 10.0.0.5         │
 │        ▼               │      (soteria dials out)   │        │               │
 │ MikroTik hub ──────────┼──── 10.0.0.254 ◄═══════════┿═══ wg0 tunnel          │
 │ 192.168.88.1           │                            │        │ ip_forward     │
 │ wg0: 10.0.0.254        │                            │        ▼               │
 └───────────────────────┘                            │ PBS (Debian)           │
                                                        │  LAN: 10.2.0.67        │
                                                        └───────────────────────┘

 Path PVE → PBS:  192.168.88.x → MikroTik → tunnel → soteria → 10.2.0.67
```

Address plan (adjust to reality):

| Thing                     | Value            | Where defined                     |
|---------------------------|------------------|-----------------------------------|
| soteria WG IP             | `10.0.0.5`       | `lib/world/hosts.nix`             |
| WG subnet                 | `10.0.0.0/24`    | `lib/world/hosts.nix` (router)    |
| soteria offsite LAN IP    | `10.2.0.66`      | `lib/world/hosts.nix` (static)    |
| offsite LAN subnet        | `10.2.0.0/24`    | `lib/world/networks.nix` (offsite) |
| PBS offsite LAN IP        | `10.2.0.67`*     | PBS box                           |
| soteria SSH port          | `2736`           | `system/modules/networking/ssh.nix` |

\* fill once the PBS box is assigned an address on the offsite LAN.
The offsite LAN subnet **must not overlap** your home LAN (`192.168.88.0/24`)
or the WG subnet (`10.0.0.0/24`).

> ✅ **Subnet collision resolved (2026-08-29).** The offsite LAN originally came
> up as `10.0.0.0/24` (installer got `10.0.0.67`), colliding with the home
> WireGuard subnet. The remote Xfinity LAN has been **renumbered to
> `10.2.0.0/24`** (gateway `10.2.0.1`); this is reflected in
> `lib/world/networks.nix`. soteria takes the static `10.2.0.66`. Phase 5
> WireGuard is unblocked.
>
> Note the sequencing: after renumbering, soteria re-leases/re-addresses on
> `10.2.0.x`, so the temporary install port-forward must target the new address.



---

## Phase 0 — Pre-flight (local, before touching remote hardware) ☑

1. Build soteria with the ZFS block still commented out:
   ```
   nix build .#nixosConfigurations.soteria.config.system.build.toplevel
   ```
2. Sanity-check the boot disk device in `hosts/soteria/disko.nix` (set to
   `/dev/mmcblk0`, the DXP2800's onboard 32GB eMMC). You'll re-verify live in
   Phase 2 before formatting.
3. Remote helper preps hardware:
   - Wired ethernet into the offsite LAN.
   - Boot the **NixOS minimal installer** USB.
   - At the installer console:
     ```
     sudo passwd root      # temporary install password
     ip -4 addr            # note the installer's LAN IP
     systemctl status sshd # ensure sshd is running (start if not)
     ```

## Phase 1 — Remote networking to reach the installer over WAN ☑

Installer LAN IP: the box first came up as `10.0.0.67` on the pre-renumber LAN.
After the LAN is renumbered to `10.2.0.0/24`, the installer re-leases on
`10.20.0.x` — read the current value with `ip -4 addr` and point the
port-forward at that address.

1. On the **remote router**, add a temporary port forward:
   `WAN TCP 22 → <installer-LAN-IP>:22`.
2. Get the remote site's **public IP**.
3. From home, confirm reachability:
   ```
   ssh root@<remote-public-ip>   # port 22, temporary installer password
   ```

> This WAN:22 exposure exists **only** for the install window. It is removed in
> Phase 2. After install, soteria listens on 2736 and is reached via WireGuard,
> so no permanent inbound rule is ever needed at the remote site.

## Phase 2 — Install with nixos-anywhere across WAN ☑

1. Verify the real target disk first:
   ```
   ssh root@<remote-public-ip> "lsblk -dpno NAME,SIZE,MODEL"
   ```
   If the boot device isn't `/dev/mmcblk0` (the onboard eMMC), fix
   `hosts/soteria/disko.nix`.
2. Install:
   ```
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#soteria \
     --ssh-port 22 \
     root@<remote-public-ip>
   ```
   This partitions per disko (ESP + 2G swap + ext4 root — **no ZFS yet**),
   installs the closure, and reboots.
3. After reboot soteria comes up on the offsite LAN listening on SSH **2736**.
   Have the helper **delete the WAN:22 port forward** now.

## Phase 3 — Stable identity on the remote LAN ☑

Pick one:
- **Preferred: DHCP reservation** — pin soteria's MAC → a fixed LAN IP on the
  remote router. Survives reinstalls, no config drift.
- **Alternative: static IP** in `hosts/soteria/default.nix` (mnemosyne has a
  commented interface example to mirror). Requires knowing the remote
  subnet/gateway.

Record soteria's offsite LAN IP — needed until WireGuard is up.

## Phase 4 — Secrets: register soteria's age key ☑

soteria's sops age key is derived from its SSH host key (generated at install).
To let it decrypt secrets later (replication creds, etc.):

1. Read the age public key:
   ```
   ssh -p 2736 root@<soteria-ip> "cat /var/lib/sops-nix/key.txt | age-keygen -y"
   ```
   (or use the `sops-age-key-display` service in
   `system/modules/system/sops_v2.nix`).
2. Add it to `.sops.yaml` under `&hosts` as `&soteria age1...`, and to any
   `creation_rules` key group soteria needs.
3. `sops updatekeys <file>` on affected secrets; commit.

## Phase 5 — WireGuard (wg-home) for a permanent private path ☑

1. **world config** — in `lib/world/hosts.nix` give soteria:
   ```nix
   soteria = {
     ip = mkIp "10.2.0.66";                  # offsite LAN static (Phase 3)
     wireguard.ip = mkIp "10.0.0.5";         # next free WG address
     wireguard.public_key = mkIp "<fill after first activation>";
   };
   ```
   The offsite LAN subnet itself lives in `lib/world/networks.nix` under
   `custom.world.networks.offsite` (a network fact, not a host fact).
   (`wg-home.nix` auto-generates the private key on first activation; read the
   public half with `wg pubkey < /root/wireguard/soteria-wg0-private.key`, then
   fill `public_key` and redeploy — same bootstrap as the other spokes.)
2. **Import wg-home** in `hosts/soteria/default.nix`:
   ```nix
   ../../system/modules/networking/wireguard/wg-home.nix
   ```
3. **Register soteria as a peer on the MikroTik hub** — see Phase 9 (the peer's
   `allowed_address` must include both its `/32` *and* the offsite subnet).
4. Verify: `ssh -p 2736 gideon@10.0.0.5`.
5. Point soteria's SSH `HostName` (in `users/gideon/configs/ssh/ssh.nix`) and
   its `pushbuild` target at the **WG IP**. All future deploys go over the
   tunnel — `pushbuild soteria`.

### 5a. Stable hub endpoint (survive a home WAN-IP change) ☑

soteria dials the home hub to establish the tunnel. If a power outage reboots
the home router and the ISP hands out a **new WAN IP**, a hardcoded-IP endpoint
would strand soteria on the stale address — and the tunnel is the only way back
in to fix it. Two independent pieces close this:

1. **Endpoint is a hostname, not an IP.** `router.wireguard.endpoint` in
   `lib/world/hosts.nix` is now the single source of truth. It is set to the
   home DNS record `mhtfiytjkhtuy.gideonwolfe.xyz` (A record pointed at the
   home connection):
   ```nix
   wireguard.endpoint = "mhtfiytjkhtuy.gideonwolfe.xyz";
   ```
   A **manually maintained** record is fine; residential IPs rarely change.
   (DDNS only *automates* this record — it buys nothing you can't do by hand,
   except shrinking the window when an IP changes while you're unavailable.)
2. **Re-resolve timer.** The WG kernel module resolves `endpoint` only ONCE at
   setup, so `wg-home.nix` ships a `wg-reresolve-dns` systemd timer (every
   2 min) that re-runs `wg set ... endpoint <host:port>`. After you update the
   DNS record, soteria picks up the new IP within ~2 min without a reboot. It's
   a no-op when the IP is unchanged (won't churn the handshake) and harmless on
   LAN spokes.

Net effect: rare IP change → edit one DNS record → soteria self-recovers. No
regular maintenance.

## Phase 6 — Create the ZFS pool + datasets (manual) ☑

Over SSH on soteria. Adjust vdev topology to the DXP2800's bay count.

1. Identify data disks by stable id:
   ```
   ls -l /dev/disk/by-id/ | grep -v part
   ```
2. Create the pool (example mirror; use raidz for more bays):
   ```
   zpool create -o ashift=12 -O compression=lz4 -O atime=off \
     -O xattr=sa -O acltype=posixacl -O mountpoint=/tank \
     tank mirror /dev/disk/by-id/<diskA> /dev/disk/by-id/<diskB>
   ```
3. Two top-level roles:
   ```
   # Replication landing zone (read-only, syncoid-owned)
   zfs create tank/backups
   zfs set readonly=on tank/backups

   # PBS datastore backend (PBS does its own dedup/compress; keep ZFS light)
   zfs create -o compression=off -o recordsize=1M tank/pbs
   ```
4. Replica child datasets (match the sources enabled in
   `zfs/zfs-replication.nix`); syncoid can also auto-create these:
   ```
   zfs create tank/backups/personal
   zfs create -p tank/backups/infra/services
   zfs create -p tank/backups/infra/vms/backups
   ```
5. Export/import test so boot import behaves:
   ```
   zpool export tank && zpool import tank
   ```

## Phase 7 — Enable the ZFS-dependent config ☑

1. In `hosts/soteria/default.nix`, uncomment the ZFS/NFS/service block and the
   matching `custom.services.*` settings.
2. In `zfs/zfs-snapshots.nix`, set `backups/*` to **prune-only**
   (`autosnap = false`) — syncoid brings snapshots over, so don't
   double-snapshot replicas. Give `tank/pbs` only a light safety snapshot.
3. Deploy over WG: `pushbuild soteria`.
4. Verify: `zpool status`, `systemctl status zfs-import-tank`, sanoid timer,
   prometheus zfs exporter.

## Phase 8 — Replication + PBS storage ◐

### 8a. ZFS replication (soteria pulls from mnemosyne) ◐ — RESUME POINT

Done so far:
- Dedicated sops-managed pull key: `hosts/soteria/zfs/secrets_syncoid.yaml`
  (git-tracked, encrypted for `*soteria`); referenced via
  `sshKey = config.sops.secrets."syncoid/id_ed25519".path`.
- Restricted source user: `hosts/mnemosyne/zfs/syncoid-source.nix` (imported into
  mnemosyne's `zfs.nix`) with soteria's public key. Delegated on mnemosyne:
  `zfs allow syncoid send,snapshot,hold tank/media/games`.
- mnemosyne now snapshots `tank/media/games` (added to its sanoid, `media` template).
- `lzop`/`mbuffer`/`pv` added to BOTH hosts for compressed/buffered transport.
- soteria `zfs/zfs-replication.nix` active: pulls `tank/media/games` →
  `tank/backups/media/games`, `commonArgs` includes `--no-sync-snap`,
  `--sshoption=Port=2736`, `--source-bwlimit=2m`. mnemosyne host key pinned in
  `programs.ssh.knownHosts` (bracketed `[ip]:2736` form).
- **First seed is RUNNING** with the hourly timer masked (manual control).

**When the seed finishes** (`zfs list -t snapshot tank/backups/media/games`
shows the snapshot and `ls /tank/backups/media/games` works):
```
sudo systemctl start syncoid-syncoid-192.168.88.205-tank-media-games.timer  # re-arm hourly incrementals
```

**Then roll out the remaining datasets** (per one, using the same recipe):
1. Ensure mnemosyne's sanoid snapshots it (add to `zfs-snapshots.nix` if not).
2. `zfs allow syncoid send,snapshot,hold tank/<dataset>` on mnemosyne.
3. Add a `commands` entry + matching prune template/target in soteria's
   `zfs-replication.nix` / `zfs-snapshots.nix`; create the target parent dataset.
4. Controlled seed (mask timer → manual start → re-arm).
   Candidates: `tank/personal`, `tank/infra/services`, `tank/infra/vms/backups`.
   (The empty `tank/backups/{bucket,personal,infra/*}` datasets already exist as
   placeholders.)

### 8b. PBS backend ☐ (not started)

Add a scoped NFS export of `tank/pbs` to only the PBS IP in
`hosts/soteria/nfs/nfs.nix`, mount on PBS, add as a datastore, configure
prune/GC/verify there. (Depends on Phase 9/10 offsite-compute work.)

---

## Phase 9 — Let the local Proxmox cluster reach remote PBS (Option 1 routing) ☐

**Problem:** the PVE nodes are Debian and are **not** WireGuard clients, so they
have no `wg0` and no route to `10.0.0.0/24` or the offsite LAN. We solve this
*without* installing WireGuard on the Debian boxes, by making the home hub and
soteria do the routing.

**Path:** `PVE (192.168.88.x) → MikroTik → tunnel → soteria → PBS (10.2.0.67)`

Because the MikroTik is already the PVE nodes' default gateway, and it will
learn the route to the offsite subnet, **the PVE nodes need no per-node static
route** — everything they don't have a route for goes to the gateway, which
knows the tunnel path.

### 9a. MikroTik — extend soteria's peer to carry the offsite subnet ☐

Cryptokey routing: the router will only send packets into the tunnel for
prefixes listed in soteria's peer `allowed_address`. Add the offsite subnet
alongside soteria's `/32`. In `hosts/network/terranix/router/wireguard.nix`,
add a peer block mirroring the existing ones:

```nix
resource."routeros_interface_wireguard_peer"."soteria" = {
  interface = "\${routeros_interface_wireguard.wg0.name}";
  name = "soteria";
  public_key = config.custom.world.hosts.soteria.wireguard.public_key;
  allowed_address = [
    "${config.custom.world.hosts.soteria.wireguard.ip}/32"  # soteria itself
    "${config.custom.world.networks.offsite.subnet}"         # offsite LAN behind it
  ];
  provider = "routeros.router";
};
```

### 9b. MikroTik — route the offsite subnet into the tunnel ☐

So the router forwards LAN-originated traffic for the offsite subnet out `wg0`.
Mirror the existing `routeros_ip_route.wg0`:

```nix
resource."routeros_ip_route"."soteria_site" = {
  dst_address = config.custom.world.networks.offsite.subnet; # 10.2.0.0/24
  gateway = "\${routeros_interface_wireguard.wg0.name}";
  provider = "routeros.router";
};
```

> The existing `wg0_forward_from_lan` filter already permits LAN → wg0
> forwarding, so no new firewall rule is required for the outbound direction.

Apply with the usual terranix/terraform run for the router.

### 9c. soteria — forward from the tunnel into its offsite LAN ☐

soteria receives tunnel packets destined `10.20.0.x` (the router sends them
because of 9a) and must forward them onto its local LAN, then masquerade so PBS
sees soteria as the source and replies come back through soteria. Add to
`hosts/soteria/default.nix` (or a small `soteria/gateway.nix` module):

```nix
# Act as the WG gateway for the offsite LAN so the home Proxmox cluster can
# reach the PBS box through the tunnel without PBS running WireGuard.
boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

networking.nat = {
  enable = true;
  externalInterface = "<soteria-offsite-nic>";   # e.g. enp1s0
  internalInterfaces = [ "wg0" ];
};
```

Return path is already handled: soteria's `wg-home.nix` peer `allowedIPs`
include the home LAN (`router.subnet`), so soteria knows how to route replies
back through the tunnel.

### 9d. Point PBS/PVE at the datastore ☐

- If PBS runs **on** soteria: PVE targets `10.0.0.5` (soteria's WG IP) directly.
- If PBS is a **separate box** (this plan): PVE targets PBS's offsite IP
  `10.2.0.67`; traffic flows via the path above.

Add the PBS datastore in the Proxmox UI and run a test backup. Verify the path
end-to-end from a PVE node:
```
ping 10.2.0.67          # should traverse hub → tunnel → soteria → PBS
```

> **End state note:** this Option 1 routing is the flake-native interim. The
> eventual mesh overlay (Netbird) would give every box — including the Debian
> PVE/PBS nodes — a stable overlay IP with automatic routing, retiring 9a–9c.

---

## Phase 10 — Offsite compute & disaster recovery (two ThinkCentres) ☐

Alongside soteria, two **Lenovo ThinkCentre M700s** (16GB RAM, 256GB SSD each)
provide offsite *compute*. soteria stores backups; these boxes run PBS and
provide somewhere to actually restore VMs during a home outage. They are
Debian/Proxmox, so they live outside the flake — documented here for cohesion.

### Design decisions

- **Standalone, NOT a 2-node cluster.** A 2-node PVE cluster is unsafe:
  Corosync needs quorum, and with 2 votes the survivor freezes if either node
  reboots. Both boxes run **standalone** (no shared cluster config).
- **PBS bare-metal**, not nested in a VM — it's I/O/verify-heavy and must stay
  up to serve restores even if the other box is down. Its datastore lives on
  soteria's ZFS (`tank/pbs` over NFS), so the PBS host is nearly stateless.
- **The second box is a standalone PVE node** — the compute where offsite DR
  restores actually boot. You need *both* a backup store (PBS) and somewhere to
  run the restore; this box is the "somewhere."

### Role assignment

| Box            | Role                                  | Storage                                  |
|----------------|---------------------------------------|------------------------------------------|
| soteria        | ZFS NAS: replication + PBS datastore  | big `tank` pool                          |
| ThinkCentre-A  | Bare-metal **PBS**                     | OS local; datastore = soteria NFS `tank/pbs` |
| ThinkCentre-B  | Standalone **PVE** (DR compute) + PDM  | `OS` + `datapool` (ZFS, matches home nodes) |

### ThinkCentre-B disk layout (for restore compatibility) ☐

Partition the 256GB SSD so its PVE storage matches the home nodes, letting a
home-taken backup restore into an identically-named target with no reconfig:

```
nvme0n1
├── OS       (~40-60GB)  Proxmox install (ZFS or ext4 root)
└── datapool (rest)      ZFS pool exposed as PVE storage ID "datapool"
```

- **Storage ID must be `datapool`** (matches home PVE nodes) — this is what PBS
  restore targets by name.
- **Storage type = ZFS** to match the home `datapool` (confirmed ZFS), so disk
  formats line up cleanly on restore.
- **Capacity reality:** ~200GB of `datapool` means DR = "boot the few must-have
  VMs," not "restore everything." Identify DR-critical VMs now; any VM whose
  disk exceeds the free space here cannot be restored to this box.

### Proxmox Datacenter Manager (PDM) ☐

Run **PDM offsite** as an LXC on ThinkCentre-B (it's a lightweight control
plane). Rationale: if PDM ran only at home, a home outage — the exact disaster
being guarded against — would take out the management plane just when it's
needed to drive the offsite restore. Running it offsite means it survives and
can orchestrate the offsite PVE node. (Optionally run a second PDM at home for
day-to-day convenience, but the offsite instance is the DR-resilient one.)

### DR flow this enables

1. Home site goes down.
2. PBS (ThinkCentre-A) still holds all VM backups on soteria's `tank/pbs`.
3. PDM (ThinkCentre-B) is up; restore a critical VM from PBS → box B's
   `datapool`.
4. Boot it on ThinkCentre-B, reachable over the WireGuard tunnel.

### Open items to confirm before building ☐

- [ ] Keep both ThinkCentres **standalone** (chosen) — no QDevice needed.
- [ ] ThinkCentre-B `datapool` created as **ZFS** with storage ID `datapool`.
- [ ] Home `datapool` dataset/volume properties noted so box B matches (ashift,
      compression) for clean ZFS restores.
- [ ] DR-critical VM list identified and confirmed to fit in ~200GB.
- [ ] PDM LXC provisioned on ThinkCentre-B.

---

## Gotchas checklist

- [ ] Remote helper removes the **WAN:22** port forward after install.
- [ ] DHCP reservation (or static) so soteria's offsite IP is stable.
- [ ] soteria age key added to `.sops.yaml` + `sops updatekeys`.
- [ ] WG `public_key` filled into `lib/world/hosts.nix` after first activation,
      then redeploy.
- [ ] soteria registered as a **peer on the MikroTik** (9a) — the hub won't
      route to it otherwise.
- [ ] Offsite LAN subnet does **not** overlap `192.168.88.0/24` or
      `10.0.0.0/24`.
- [ ] Switch soteria's deploy/SSH target to the **WG IP** once the tunnel works.
- [ ] Confirm the real **disk device path** before disko formats.
- [ ] Decide vdev layout (mirror vs raidz) **before** `zpool create` — it's
      irreversible without destroying the pool.
- [ ] Set `backups/*` to prune-only so replicas aren't double-snapshotted.
- [ ] `ip_forward` + NAT on soteria (9c), or PVE can't reach a separate PBS box.
```
