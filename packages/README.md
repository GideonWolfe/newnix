`packages` contains lists of packages that are grouped by category. These lists can be imported by a host directly, or by a role/profile.

Custom derivations live in `custom/` and are included from the relevant category.
The gaming list includes `amethyst-mod-manager-unfree` from the pinned
`nixpkgs-unstable` input, with unfree packages enabled for that import.
Its local override adds SQLite to the native Rust extension's build inputs
to fix the upstream `cannot find -lsqlite3` linker failure.
The geography list includes Terrascope (`terrascope`), a terminal world map with
live data layers. It downloads map data into the user's cache on first use;
live weather, aircraft, and earthquake layers require network access.