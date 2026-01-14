Roles are essentially logical groupings of `modules` and `packages` to fulfill a desired `role`.

For example, a system with the `desktop` role is going to fill the role of a desktop client machine. So the `desktop.nix` role will import the appropriate modules and packages to make that happen.

This architecture allows me to change things upstream and have all downstream devices with the same role be affected.

`roles` that are commonly used together (eg. `desktop`, `hardware` and `gaming`), can be wrapped in a `profile`, such as `gaming_computer`