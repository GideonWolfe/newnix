{
  description = "Flake for all my nixos based infrastructure";

  inputs = {

    # Stable packages
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-25.11"; };

    # Unstable packages
    #nixpkgs-unstable = { url = "github:NixOS/nixpkgs/nixos-unstable"; };

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
    # nixvim = {
    #   url = "github:nix-community/nixvim/nixos-25.11";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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

    dsd-fme = { url = "github:lwvmobile/dsd-fme"; };

    #niri = { url = "github:YaLTeR/niri"; };
    niri = { url = "github:sodiboo/niri-flake"; };

  };

  outputs = { self, nixpkgs, home-manager, deploy-rs, wallpapers, stylix, sops-nix, disko, dsd-fme, niri, spicetify-nix, ...  }@inputs:
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

      # Build target and convenience alias: nix build .#poseidon
      packages.x86_64-linux.poseidon = self.nixosConfigurations.poseidon.config.system.build.toplevel;
      poseidon = self.packages.x86_64-linux.poseidon;

      ###################
      # Test Proxmox VM #
      ###################



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
