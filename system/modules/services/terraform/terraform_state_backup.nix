# This file sets up a regular backup of the terraform state files to a remote location
# Since i'm the only user and generally only work from one machine, I don't need anything fancy like remote state storage or locking. 
# I just want to have a backup of the state files in case something goes wrong with my local machine.
{ config, lib, ... }:
let
    # This is the root directory where all my terraform infrastructure will be contained
    terraformWorkingDir = "/home/gideon/infra/";
    terraformProxmoxDir = "${terraformWorkingDir}/home/proxmox";
    backupDir = "/nas/tank/backups/terraform/";
in
{
    services.restic.enable = true;
    services.restic.backups."terraform-proxmox-state" = {
        # Directory to back up
        paths = [ "${terraformProxmoxDir}" ];
        # Back up to the NAS
        repository = "${backupDir}/proxmox";
        # Daily backup
        timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
        };
        # Create the backup repository if it doesn't exist and initialize it with the provided password
        initialize = true;
        passwordFile = "${config.sops.secrets.terraform.ProxmoxStatePassword.path}";
    };
}