{ config, lib, pkgs, inputs, ... }:
# Enable the System Wide SOPS module
# Doesn't do anything unless actual secrets are defined
# By default, users import their own secrets in their user modules
{
  imports = [
    # The import here makes the module available systemwide.
    # Even if the feature is disabled, we want the module to be available
    # so that modules won't break when referencing it
    inputs.sops-nix.nixosModules.sops
  ];


  # Ensure SSH is enabled so host keys get generated
  services.openssh.enable = lib.mkDefault true;

  # Ensure sops and age are available as user commands
  environment.systemPackages = with pkgs; [
    sops
    age
  ];

  # SOPS configuration
  sops = {
    # Required to prevent bug from importing wrong keys
    gnupg.sshKeyPaths = [ ];

    # AGE key configuration
    age = {
      # Tell SOPS where to find the host private key
      # This will be used to go from Private SSH -> Private AGE key
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      # This is where the host private AGE key lives
      keyFile = "/var/lib/sops-nix/key.txt";

      # If the private AGE key doesn't exist (like on a new system), create it
      generateKey = true;
    };
  };

  systemd.services.sops-age-keygen = {
    description = "Ensure SOPS AGE key exists";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /var/lib/sops-nix
      if [ ! -f /var/lib/sops-nix/key.txt ]; then
        ${pkgs.age}/bin/age-keygen -o /var/lib/sops-nix/key.txt
      fi
    '';
  };


}