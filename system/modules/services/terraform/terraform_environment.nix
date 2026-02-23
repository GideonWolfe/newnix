{pkgs, ... }:
# This file sets up the staging area where I can launch terraform commands.
# The flow is: 
#   Terranix generates terraform configuration files
#   SOPS-nix generates the secrets file terraform needs to authenticate various platforms
#   A systemd service seeds the terraform working directory with the generated secrets file
#   Building the desired terraform package in my flake with -o /terraform/staging/dir will update the terraform config
let
    # This is the root directory where all my terraform infrastructure will be contained
    terraformWorkingDir = "/home/gideon/infra/";
    # Specific directories that will be used for different terraform modules
    terraformProxmoxDir = "${terraformWorkingDir}/home/proxmox";
    terraformNetworkDir = "${terraformWorkingDir}/home/network";
    # Build the generator once and reuse the absolute path so systemd can find it
    generateTerraformProxmox = pkgs.writeShellScriptBin "generate-terraform-proxmox" ''
      #!/usr/bin/env bash
      set -euo pipefail
      nix build /home/gideon/test/newnix/.#terranix_proxmox -o ${terraformProxmoxDir}/config.tf.json
    '';
in
{


# Step 1: we need a service that will ensure these directories exist and are owned by the right user
  systemd.services.terraform-create-dir = {
    description = "Create Terraform staging area";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      # Create the main working directory and subdirectories for different terraform modules
      mkdir -p ${terraformProxmoxDir}
      mkdir -p ${terraformNetworkDir}
      # Make sure I'm the owner
      chown -R 1000:100 ${terraformWorkingDir}
      chmod 755 ${terraformWorkingDir}
    '';
  };

  # systemd.services.terraform-proxmox-init = {
  #   description = "Initialize Terraform Proxmox module";
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.Type = "oneshot";
  #   # Only runs if the terraform directory exists but hasn't been initialized yet (i.e. no .terraform directory)
  #   serviceConfig.ConditionPathExists = "!{${terraformProxmoxDir}/.terraform}";
  #   # Run as the repo owner so git/nix don't reject access to the checked-out flake
  #   serviceConfig.User = "gideon";
  #   serviceConfig.Group = "users";
  #   #serviceConfig.Environment = [ "HOME=/home/gideon" ];
  #   # Ensure PATH contains the generator command and nix for the build step
  #   path = [ generateTerraformProxmox pkgs.nix ];
  #   script = ''
  #     set -e
  #     cd ${terraformProxmoxDir}
  #     ${pkgs.opentofu}/bin/tofu init
  #     ${generateTerraformProxmox}/bin/generate-terraform-proxmox
  #   '';
  # };


  # Step 2: Make a command available that will generate the terraform configuration files in the staging area when I run it
  environment.systemPackages = [
    generateTerraformProxmox
  ];
}