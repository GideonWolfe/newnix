
# Patterns and Guidelines

1. **Consistency**: Follow the existing patterns in the codebase for naming, structuring, and organizing files and configurations.
2. **Modularity**: Keep configurations modular and reusable. Avoid hardcoding values that can be derived from existing configurations or variables.
3. **Documentation**: Document any new configurations or changes clearly, both in code comments. Don't overdo the comments, try to keep them to a line or two.
4. **Pushback** : If you encounter a situation where you think the existing patterns are not sufficient or could be improved, feel free to suggest changes or improvements. However, be prepared to justify your suggestions and consider the impact on the overall codebase.

# Skills

## Adding a new host
To add a new host to the system, you need to follow these steps:

1. New entry `hosts/`:
  - If the host is a physical machine:
    - Create a new configuration file in `hosts/
  - If the host is a proxmox VM:
    - Create a new VM configuration file in `hosts/proxmox/vms/`
2. New entry in `flake.nix`
3. Add the host's IP address to `lib/world/hosts.nix`
4. Add the host entry to `users/gideon/configs/ssh/ssh.nix` for SSH access
5. Add the host entry to `home/apps/shell/fish/functions/pushbuild.nix` for easy access to `pushbuild`

## Adding a new service
To add a new service to the system, you need to follow these steps:

1. Create a new service configuration in `lib/world/services.nix`
2. Create a new directory for the service config to live in `/system/modules/server/apps/` (or a siimilar modules directory if appropriate)
3. Add the service configuration to the appropriate VM configuration in `hosts/proxmox/vms/`
4. If the service requires a domain, remind the user to add the domain configuration to your DNS provider and point it to the appropriate IP address
5. If the service requires a domain and is in my proxmox stack, make sure to add a route for the traffic in the `traefik` configuration (each service gets its own file)

## Packaging an application
To package an application for deployment on the system, you need to follow these steps:

All my custom applications live under `packages/custom`. That's where the derivation will live, and then we import it into the appropriate package list under the other `packages/` subdirectories.