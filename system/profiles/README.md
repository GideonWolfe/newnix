`system/profiles` contains high-level, opinionated collections of roles. A host typically selects exactly one profile, and each profile pulls in the roles (and any shared package sets) required for that persona.

Some examples of existing or potential profiles:

- `full-workstation.nix`
- `minimal-desktop.nix`
- `minimal.nix`
- future `proxmox-vm.nix`, `digitalocean-vm.nix`, etc.


When I create a new system, I can ask myself, "what roles does this system have?"

I can answer, "this is a bare metal machine that will run a full desktop environment but is not gaming capable"

If there is already a profile that utilizes that combination of roles, I can simply apply it. If not, I can create it easily with just a few imports.

For instance, the above scenario may necessitate the creation of a "light-client" profile, that will import the necessary roles.


This is also where we can control the package sets that are imported. It doesn't really make sense to bind the packages to a role, because for instance, I could want a `desktop` role active across a variety of systems with different package needs.

However if I already have a "raspberry-pi" profile, I can easily clone it inside `system/profiles/` and add the package imports to turn it into a "retro-games-pi" or "pentesting-pi".