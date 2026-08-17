{
  description = "Flake for all my nixos based infrastructure";

  inputs = {

    # Stable packages
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };

    # Unstable packages
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # Hardware support configurations
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    # User configuration manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # My personal wallpaper collection
    wallpapers = {
      url = "github:gideonwolfe/wallpapers/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Theming engine
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Declerative disk/filesystem management
    disko = {
      url = "github:nix-community/disko/latest";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Configure neovim with Nix!
    # Note: no `nixpkgs.follows` here -- nixvim pins its own nixpkgs and
    # overriding it triggers a source-mismatch warning.
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };

    # Secret Management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deployment tool
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Terraform Generator
    terranix = {
      url = "github:terranix/terranix";
    };

    # cool visualizer
    xyosc = {
      url = "github:make-42/xyosc";
    };

    dsd-fme = {
      url = "github:lwvmobile/dsd-fme";
    };

    # provides some AI tools like crush (maybe redundant later)
    nix-ai-tools.url = "github:numtide/nix-ai-tools";

    niri = {
      url = "github:sodiboo/niri-flake";
    };

    # Dank Material Shell
    # TODO: programs.dms-shell is in 26.05, but not sure it comes with HM module
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Extra DMS functionality
    # TODO: these will be in 26.05, so this can be removed as flake input
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # greetd login screen matching the DMS aesthetic.
    # No `nixpkgs.follows`: upstream pins nixpkgs-unstable and needs Go 1.26+,
    # which isn't guaranteed in our stable nixpkgs.
    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter";
    };

    # liixini's GLSL shader collection for niri (not a flake, just .glsl files)
    liixini-shaders = {
      url = "github:liixini/shaders";
      flake = false;
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };

    # Lightweight file server (resumable up/downloads, webdav/ftp/smb, etc.)
    copyparty = {
      url = "github:9001/copyparty";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      home-manager,
      deploy-rs,
      terranix,
      wallpapers,
      nixvim,
      stylix,
      sops-nix,
      disko,
      dsd-fme,
      niri,
      spicetify-nix,
      dms,
      dgop,
      danksearch,
      xyosc,
      nix-ai-tools,
      liixini-shaders,
      nix-flatpak,
      copyparty,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
    in
    {

      ################
      # Example Host #
      ################
      # example host configuration
      nixosConfigurations.example-host = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/example-host ];
      };
      # Create a VM from this host
      # buld with nix build .#example-host-vm, run with nix run .#example-host-vm
      packages.x86_64-linux.example-host-vm =
        self.nixosConfigurations.example-host.config.system.build.vm;
      # Deploy remotely to this host
      deploy.nodes.vm = {
        hostname = "example-host";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.example-host;
      };

      ############
      # uConsole #
      ############
      # System definition
      nixosConfigurations.uconsole = lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/uconsole ];
      };
      # Build targets
      # buld with nix build .#uconsole-image
      # WARNING: will result in resource intensive cross-compilation
      packages.x86_64-linux.uconsole-image =
        self.nixosConfigurations.uconsole.config.system.build.sdImage;
      packages.x86_64-linux.uconsole-nixos =
        self.nixosConfigurations.uconsole.config.system.build.toplevel;
      # Remotely deploy changes (so we don't have to bake images each time)
      deploy.nodes.uconsole = {
        hostname = "192.168.0.29";
        profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.uconsole;
      };

      ############
      # Poseidon #
      ############
      # System definition
      nixosConfigurations.poseidon = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/poseidon ];
      };

      #########
      # Hades #
      #########
      # System definition
      nixosConfigurations.hades = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/hades ];
      };

      # Build target and convenience alias: nix build .#poseidon
      packages.x86_64-linux.poseidon = self.nixosConfigurations.poseidon.config.system.build.toplevel;
      poseidon = self.packages.x86_64-linux.poseidon;

      ###################
      # Base Proxmox VM #
      ###################
      # Base config for proxmox VM without any specific role
      # Can be used to generate image that can be deployed on proxmox
      # Then a more specific VM role can be layered on top and deployed to the running base VM
      # Alternatively, the specific VM role can be deployed directly
      # with nixos-anywhere if the VM just boots a NixOS ISO
      nixosConfigurations.proxmox-base = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/proxmox ];
      };
      packages.x86_64-linux.proxmox-test-vm =
        self.nixosConfigurations.proxmox-base.config.system.build.vm;

      # Build a Proxmox VMA image using upstream module imported in the host config
      packages.x86_64-linux.proxmox-base-vma =
        self.nixosConfigurations.proxmox-base.config.system.build.VMA;
      # Media VM
      nixosConfigurations.vm-media = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/proxmox
          ./hosts/proxmox/vms/media
        ];
      };
      # App1 VM
      nixosConfigurations.vm-app1 = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/proxmox
          ./hosts/proxmox/vms/app1
        ];
      };

      # App2 VM (lives on pve3)
      nixosConfigurations.vm-app2 = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/proxmox
          ./hosts/proxmox/vms/app2
        ];
      };

      # Ingress VM
      nixosConfigurations.vm-ingress = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/proxmox
          ./hosts/proxmox/vms/ingress
        ];
      };

      # Test VM (sandbox on pve3 for trying new server roles)
      nixosConfigurations.vm-test = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/proxmox
          ./hosts/proxmox/vms/test
        ];
      };
      #########################
      # Mnemosyne (Local NAS) #
      #########################
      nixosConfigurations.mnemosyne = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/mnemosyne ];
      };
      deploy.nodes.mnemosyne = {
        hostname = "192.168.0.137";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mnemosyne;
        profiles.system.user = "root";
      };

      # Terraform
      packages.x86_64-linux.terranix_proxmox = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          ./hosts/proxmox/terranix/provider.nix
          ./hosts/proxmox/terranix/vm-ingress.nix
          ./hosts/proxmox/terranix/vm-media.nix
          ./hosts/proxmox/terranix/vm-app1.nix
          ./hosts/proxmox/terranix/vm-app2.nix
          ./hosts/proxmox/terranix/vm-test.nix
          #./hosts/proxmox/terranix/vm-network.nix
        ];
      };

      packages.x86_64-linux.terranix_routeros = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          ./lib/world/default.nix
          ./hosts/network/terranix/provider.nix
          ./hosts/network/terranix/router/dhcp_leases.nix
          ./hosts/network/terranix/router/port_forwards.nix
          ./hosts/network/terranix/router/dns.nix
          ./hosts/network/terranix/router/wireguard.nix
          # IoT VLAN, staged rollout: apply Stage A (vlan_iot) and verify LAN +
          # DHCP lease before enabling Stage B (firewall_iot) isolation rules.
          ./hosts/network/terranix/router/vlan_iot.nix
          ./hosts/network/terranix/router/firewall_iot.nix
        ];
      };

      packages.x86_64-linux.terranix_netbox = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          # Give access to all our variables in our TF configs
          ./lib/world/default.nix
          # All NetBox resources are aggregated in this directory's default.nix
          ./system/modules/server/apps/netbox/terranix
        ];
      };

      # deploy-rs global settings
      deploy = {
        sshUser = "gideon";
        #sshOpts = [ "-i" "/home/gideon/.ssh/gideon_ssh_sk" "-p" "2736"];
        sshOpts = [
          "-i"
          "/home/gideon/.ssh/gideon_ssh_sk"
        ];
        user = "root";
        fastConnection = true;
        interactiveSudo = true;
      };
      # Deploy checks to run before deployment
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    };

}
