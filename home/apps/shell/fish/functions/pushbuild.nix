{ lib, config, osConfig }:

# Build the local flake and push it to a remote host over SSH.
#
# Usage:
#   pushbuild                 # interactive: fzf-pick a nixosConfiguration,
#                             # IP is auto-resolved from world config
#                             # (you'll only be prompted if it's not known)
#   pushbuild <host>          # build .#<host>, auto-resolve IP from world config
#   pushbuild <host> <ip>     # explicit override of the target IP/hostname
#
# Adding a new host: drop one line in `hostMap` below, that's it. The
# mapping is the single source of truth for flake-attr -> IP and is
# baked into the fish function at HM activation time, so the function
# never has to grep the flake at runtime.

let
  h = osConfig.custom.world.hosts;

  # flake attribute name  ->  IP / hostname for --target-host
  hostMap = {
    "vm-media"   = h.proxmox.vms.vm_media.ip;
    "vm-app1"    = h.proxmox.vms.vm_app1.ip;
    "vm-ingress" = h.proxmox.vms.vm_ingress.ip;
    "vm-test"    = h.proxmox.vms.vm_test.ip;
    "mnemosyne"  = h.mnemosyne.ip;
    "poseidon"   = h.poseidon.ip;
    "hades"      = h.hades.ip;
  };

  # Generate fish switch cases: `case "vm-media"; set default_host "192.168.88.102"`
  caseLines = lib.concatStringsSep "\n      "
    (lib.mapAttrsToList
      (name: ip: ''case "${name}"; set default_host "${ip}"'')
      hostMap);

  # Generate the list of known flake attrs (for fzf and listing)
  knownHosts = lib.concatStringsSep " "
    (map (n: ''"${n}"'') (lib.attrNames hostMap));

  sshPort = toString (builtins.head osConfig.services.openssh.ports);
in
{
  body = ''
    set -l ssh_opts "-p ${sshPort} -i ${config.home.homeDirectory}/.ssh/gideon_ssh_sk"
    set -l known_hosts ${knownHosts}

    set -l flake_attr
    set -l target_host
    set -l interactive 0

    # ---- parse args -------------------------------------------------
    switch (count $argv)
      case 0
        # Interactive: fzf the known list, then ALWAYS prompt for an IP
        set interactive 1
        if not command -q fzf
          echo "pushbuild: fzf required for interactive selection" >&2
          return 1
        end
        set flake_attr (printf '%s\n' $known_hosts | fzf --prompt="host> " --height=40% --reverse)
        if test -z "$flake_attr"
          echo "pushbuild: no selection, aborting" >&2
          return 1
        end
      case 1
        set flake_attr $argv[1]
      case '*'
        set flake_attr $argv[1]
        set target_host $argv[2]
    end

    # ---- resolve a default IP from the Nix-generated map ------------
    set -l default_host ""
    switch "$flake_attr"
      ${caseLines}
      case '*'
    end

    # Interactive mode: always ask for IP, suggesting the mapped default.
    if test $interactive -eq 1
      if test -n "$default_host"
        read -P "target host for $flake_attr [$default_host]: " target_host
        if test -z "$target_host"
          set target_host "$default_host"
        end
      else
        read -P "target host (IP/hostname) for $flake_attr: " target_host
      end
      if test -z "$target_host"
        echo "pushbuild: no target host given, aborting" >&2
        return 1
      end
    else if test -z "$target_host"
      # Non-interactive: fall back to map, or prompt only as a last resort.
      if test -n "$default_host"
        set target_host "$default_host"
      else
        echo "pushbuild: '$flake_attr' is not in the known host map." >&2
        echo "  known hosts: $known_hosts" >&2
        read -P "  enter target host (IP/hostname) to use anyway: " target_host
        if test -z "$target_host"
          echo "pushbuild: no target host given, aborting" >&2
          return 1
        end
      end
    end

    echo "pushbuild: building .#$flake_attr -> $target_host"
    NIX_SSHOPTS="$ssh_opts" nixos-rebuild switch \
        --flake "/home/${config.home.username}/test/newnix/.#$flake_attr" \
        --target-host "$target_host" \
        --ask-sudo-password
  '';
}
