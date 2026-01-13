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

    # Declerative disk/filesystem management
    # disko = {
    #   url = "github:nix-community/disko/latest";
    #   inputs = { nixpkgs.follows = "nixpkgs"; };
    # };

    # Theming engine
    # stylix = {
    #   url = "github:nix-community/stylix/release-25.11";
    #   inputs = { nixpkgs.follows = "nixpkgs"; };
    # };

    # Configure neovim with Nix!
    # nixvim = {
    #   url = "github:nix-community/nixvim/nixos-25.11";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Secret Management
    # sops-nix = {
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Deployment tool
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };


  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, stylix, 
    nixvim, sops-nix, deploy-rs, disko, ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in {


      ################
      # Example Host #
      ################

      # example host configuration
      nixosConfigurations.example-host = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/vm.nix ];
      };

      # Create a VM from this host
      # buld with nix build .#example-host-vm, run with nix run .#example-host-vm
      packages.x86_64-linux.exmaple-host-vm = self.nixosConfigurations.example-host.config.system.build.vm;

      # Deploy remotely to this host
      deploy.nodes.vm = {
        hostname = "example-host";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.example-host;
      };





      # deploy-rs global settings
      deploy = {
        sshUser = "gideon";
        sshOpts = [ "-i" "/home/gideon/.ssh/gideon_ssh_sk" "-p" "2736"];
        user = "root";
        fastConnection = true;
        interactiveSudo = true;
      };
      # Deploy checks to run before deployment
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;



    };

}
