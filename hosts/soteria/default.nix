{ lib, inputs, pkgs, config, ... }:
  
{
  imports = [
    # Partitioning configuration for boot drive
    # Only run on install
    ./disko.nix

    # Boot loader configuration for EFI systems
    ../../system/modules/system/systemd-boot.nix

    # This host uses my default user configuration
    ../../users/gideon/default.nix
    # This host uses my personal secrets and accounts
    #../../users/gideon/personal.nix

    # MINIMAL profile: soteria boots from a 32GB eMMC, so it must stay lean.
    # Unlike mnemosyne (light-workstation + always-on Grafana panel), this box
    # is headless — no desktop, no app suites. Just base system + the NAS bits.
    ../../system/profiles/minimal.nix

    # Monitoring AGENT (exporters + Alloy shipping to the home stack). This is
    # the lightweight agent role, NOT the full server aggregator. zfs-monitoring.nix
    # appends its scrape job to the Alloy config this provides. soteria's age key
    # is registered in .sops.yaml so the push-password secret decrypts fine.
    ../../system/roles/monitoring.nix

    #############
    # NAS Stuff #
    #############
    # CPU modules and stuff for NAS hardware
    ../../system/modules/hardware/ugreen-nas.nix # This is the UGREEN NAS box, so it needs the hardware tweaks for that
    # HDD monitoring with smartd and scrutiny
    ../../system/roles/hdds.nix 

    # WireGuard tunnel to the home hub. soteria dials out to the hub (via the
    # DNS endpoint) so all home<->offsite traffic rides the tunnel. First
    # activation generates soteria's keypair at
    # /root/wireguard/soteria-wg0-private.key; read its public half, put it in
    # lib/world/hosts.nix (soteria.wireguard.public_key), and register soteria
    # as a peer on the MikroTik before the tunnel will come up.
    ../../system/modules/networking/wireguard/wg-home.nix

    # NOTE: intentionally NOT importing system/roles/hardware.nix — that role is
    # for desktop/physical-access machines (bluetooth, printing, SDR, gaming
    # peripherals, KDE Connect, etc.) and would bloat the eMMC closure. The NAS
    # only needs the ugreen-nas hardware module and smartd/scrutiny above.

    #####################################################################
    # ZFS + NFS (Phase 7: pool + datasets now exist).                   #
    # Replication (syncoid) stays deferred inside zfs/zfs.nix until the  #
    # monitoring stack is confirmed working end-to-end.                 #
    #####################################################################
    # Services and tools to manage the ZFS pool (scrub, snapshots, monitoring)
    ./zfs/zfs.nix
    # Allow our datasets to be shared over NFS
    ./nfs/nfs.nix

    # Copyparty lightweight file server for LAN hosts without the NFS mount
    #../../system/modules/server/apps/copyparty

  ];

  # Headless box: no home-manager desktop/session/editor imports. The core HM
  # config is imported automatically; the graphical stack (niri, chromium
  # kiosk, nixvim) is intentionally omitted to keep the eMMC closure small.

  # Plymouth fills up the /boot partition lol
  boot.plymouth.enable = lib.mkForce false;

  # eMMC boot support: soteria's root is on /dev/mmcblk0 (onboard 32GB eMMC).
  # The default NixOS initrd bundles NVMe/AHCI/USB storage modules but NOT the
  # SD/eMMC host-controller modules, so without these the initrd cannot see
  # mmcblk0 and root fails to mount at boot. (mnemosyne boots from NVMe and so
  # doesn't need these.)
  boot.initrd.availableKernelModules = [ "mmc_block" "sdhci" "sdhci_pci" "sdhci_acpi" ];

  #####################################################################
  # eMMC closure trims (32GB onboard flash) — headless overrides of   #
  # things pulled in by the shared base role that a headless offsite  #
  # NAS never uses.                                                    #
  #####################################################################
  # NOTE: stylix.enable is intentionally left ON — the shared HM config
  # (e.g. fish) references config.lib.stylix.colors, so disabling it breaks
  # eval. Its cost is mostly fonts/theme data and not worth the entanglement.
  # No desktop → never launches AppImages.
  programs.appimage.enable = lib.mkForce false;
  # Docker/moby (~900MB) is only needed by the container-based file services
  # (copyparty/aria2), which are deferred to a later deploy. Re-enable this
  # (delete the override) when uncommenting those services below.
  virtualisation.docker.enable = lib.mkForce false;

  #####################################################################
  # ZFS / tank-dependent service settings (FIRST DEPLOY: commented)   #
  # Uncomment together with the imports above once the tank pool and  #
  # its datasets have been created.                                   #
  #####################################################################
  # Directory that copyparty serves as its root volume.
  # On the NAS this should point at a gideon-owned location on the tank pool.
  #custom.services.copyparty.dataDir = "/tank";

  # Give the machine a unique hostname
  networking.hostName = "soteria";

  system.stateVersion = "25.11";

}
