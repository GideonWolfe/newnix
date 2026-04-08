{
  description = "Flake for all my nixos based infrastructure";

  inputs = {

    # Stable packages
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-25.11"; };

    # Unstable packages
    nixpkgs-unstable = { url = "github:NixOS/nixpkgs/nixos-unstable"; };

    # Hardware support configurations
    nixos-hardware = { url = "github:NixOS/nixos-hardware/master"; };

    # User configuration manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };

    # My personal wallpaper collection
    wallpapers = {
      url = "github:gideonwolfe/wallpapers/master";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };

    # Theming engine
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };

    # Declerative disk/filesystem management
    disko = {
      url = "github:nix-community/disko/latest";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Configure neovim with Nix!
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
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
    terranix = { url = "github:terranix/terranix"; };

    # cool visualizer
    xyosc = { url = "github:make-42/xyosc"; };

    dsd-fme = { url = "github:lwvmobile/dsd-fme"; };

    # provides some AI tools like crush (maybe redundant later)
    nix-ai-tools.url = "github:numtide/nix-ai-tools";

    niri = { url = "github:sodiboo/niri-flake"; };

    # Dank Material Shell
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

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, deploy-rs, terranix, wallpapers, nixvim, stylix, sops-nix, disko, dsd-fme, niri, spicetify-nix, dms, dgop, danksearch, xyosc, nix-ai-tools, ...  }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
    in {


      ################
      # Example Host #
      ################
      # example host configuration
      nixosConfigurations.example-host = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/example-host
        ];
      };
      # Create a VM from this host
      # buld with nix build .#example-host-vm, run with nix run .#example-host-vm
      packages.x86_64-linux.example-host-vm = self.nixosConfigurations.example-host.config.system.build.vm;
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
        modules = [
          ./hosts/uconsole
        ];
      };
      # Build targets
      # buld with nix build .#uconsole-image
      # WARNING: will result in resource intensive cross-compilation
      packages.x86_64-linux.uconsole-image = self.nixosConfigurations.uconsole.config.system.build.sdImage;
      packages.x86_64-linux.uconsole-nixos = self.nixosConfigurations.uconsole.config.system.build.toplevel;
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
        modules = [
          ./hosts/poseidon
        ];
      };

      #########
      # Hades #
      #########
      # System definition
      nixosConfigurations.hades = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/hades
        ];
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
        modules = [
          ./hosts/proxmox
        ];
      };
      packages.x86_64-linux.proxmox-test-vm = self.nixosConfigurations.proxmox-base.config.system.build.vm;

      # Build a Proxmox VMA image using upstream module imported in the host config
      packages.x86_64-linux.proxmox-base-vma = self.nixosConfigurations.proxmox-base.config.system.build.VMA;
      # Media VM
      nixosConfigurations.media-vm = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/proxmox
          ./hosts/proxmox/vms/media
        ];
      };
      # App1 VM
      nixosConfigurations.app1-vm = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/proxmox
          ./hosts/proxmox/vms/app1
        ];
      };

      #########################
      # Mnemosyne (Local NAS) #
      #########################
      nixosConfigurations.mnemosyne = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mnemosyne
        ];
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
          #./hosts/proxmox/terranix/vm-media.nix
          #./hosts/proxmox/terranix/vm-network.nix
          #./hosts/proxmox/terranix/vm-ingress.nix
          #./hosts/proxmox/terranix/vm-app1.nix
          ./hosts/proxmox/terranix/vm-test.nix
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
        ];
      };

      packages.x86_64-linux.terranix_netbox = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          # Give access to all our variables in our TF configs
          ./lib/world/default.nix
          ./system/modules/server/apps/netbox/terranix/provider.nix
          ./system/modules/server/apps/netbox/terranix/sites/home.nix
          ./system/modules/server/apps/netbox/terranix/sites/offsite.nix
          ./system/modules/server/apps/netbox/terranix/clusters/home.nix
          ./system/modules/server/apps/netbox/terranix/rack_roles/compute.nix
          ./system/modules/server/apps/netbox/terranix/rack_roles/network.nix
          ./system/modules/server/apps/netbox/terranix/racks/home-compute-rack.nix
          ./system/modules/server/apps/netbox/terranix/racks/home-network-rack.nix
          ./system/modules/server/apps/netbox/terranix/manufacturers/mikrotik.nix
          ./system/modules/server/apps/netbox/terranix/manufacturers/lenovo.nix
          ./system/modules/server/apps/netbox/terranix/manufacturers/western_digital.nix
          ./system/modules/server/apps/netbox/terranix/manufacturers/ugreen.nix
          ./system/modules/server/apps/netbox/terranix/manufacturers/beelink.nix
          ./system/modules/server/apps/netbox/terranix/manufacturers/deskpi.nix
          ./system/modules/server/apps/netbox/terranix/device_types/mikrotik_rb5009.nix
          ./system/modules/server/apps/netbox/terranix/device_types/mikrotik_css318.nix
          ./system/modules/server/apps/netbox/terranix/device_types/mikrotik_hapax2.nix
          ./system/modules/server/apps/netbox/terranix/device_types/lenovo_m900.nix
          ./system/modules/server/apps/netbox/terranix/device_types/ugreen_dxp4800plus.nix
          ./system/modules/server/apps/netbox/terranix/device_types/beelink_u59.nix
          ./system/modules/server/apps/netbox/terranix/device_types/deskpi_patch_panel_halfu.nix
          ./system/modules/server/apps/netbox/terranix/device_types/deskpi_patch_panel_1u.nix
          ./system/modules/server/apps/netbox/terranix/device_roles/router.nix
          ./system/modules/server/apps/netbox/terranix/device_roles/switch.nix
          ./system/modules/server/apps/netbox/terranix/device_roles/access_point.nix
          ./system/modules/server/apps/netbox/terranix/device_roles/compute.nix
          ./system/modules/server/apps/netbox/terranix/device_roles/patch_panel.nix
          ./system/modules/server/apps/netbox/terranix/devices/mikrotik_rb5009.nix
          ./system/modules/server/apps/netbox/terranix/devices/mikrotik_css318.nix
          ./system/modules/server/apps/netbox/terranix/devices/mikrotik_hapax2.nix
          ./system/modules/server/apps/netbox/terranix/devices/lenovo_m900_1.nix
          ./system/modules/server/apps/netbox/terranix/devices/lenovo_m900_2.nix
          ./system/modules/server/apps/netbox/terranix/devices/lenovo_m900_3.nix
          ./system/modules/server/apps/netbox/terranix/devices/ugreen_dxp4800plus.nix
          ./system/modules/server/apps/netbox/terranix/devices/beelink_u59.nix
          ./system/modules/server/apps/netbox/terranix/devices/deskpi_patch_panel_halfu.nix
          ./system/modules/server/apps/netbox/terranix/devices/deskpi_patch_panel_1u.nix
          ./system/modules/server/apps/netbox/terranix/vms/vm-media.nix
          ./system/modules/server/apps/netbox/terranix/vms/vm-ingress.nix
          ./system/modules/server/apps/netbox/terranix/services/jellyfin.nix
          ./system/modules/server/apps/netbox/terranix/services/navidrome.nix
          ./system/modules/server/apps/netbox/terranix/services/slskd.nix
          ./system/modules/server/apps/netbox/terranix/services/soulsync.nix
          ./system/modules/server/apps/netbox/terranix/services/soulsync.nix
          ./system/modules/server/apps/netbox/terranix/services/nzbget.nix
          ./system/modules/server/apps/netbox/terranix/services/radarr.nix
          ./system/modules/server/apps/netbox/terranix/services/sonarr.nix
          ./system/modules/server/apps/netbox/terranix/services/prowlarr.nix
          ./system/modules/server/apps/netbox/terranix/services/recyclarr.nix
          ./system/modules/server/apps/netbox/terranix/services/seerr.nix
        ];
      };

      # deploy-rs global settings
      deploy = {
        sshUser = "gideon";
        #sshOpts = [ "-i" "/home/gideon/.ssh/gideon_ssh_sk" "-p" "2736"];
        sshOpts = [ "-i" "/home/gideon/.ssh/gideon_ssh_sk"];
        user = "root";
        fastConnection = true;
        interactiveSudo = true;
      };
      # Deploy checks to run before deployment
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;



    };

}
