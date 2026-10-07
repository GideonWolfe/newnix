# OpenSCAD with offline libraries

This package combines the flake-pinned `openscad-unstable` engine with the
commit- and hash-pinned sources in [libraries.nix](libraries.nix). The newer
engine provides Manifold rendering and newer language features; "unstable"
does not mean it downloads the latest version at launch.

The [CAD package set](../../science/engineering/cad.nix) installs this instead
of bare OpenSCAD. Rebuild the workstation normally to use it from the application
launcher or the `openscad` command. Existing Home Manager/Stylix settings are
unchanged. No separate flake output or development shell is needed.

Include this new package directory in Git before a normal Git-filtered flake
rebuild.

## Included libraries

| Library | Purpose |
| --- | --- |
| [BOSL2](https://github.com/BelfrySCAD/BOSL2) | Shapes, attachments, threads, gears, rounding |
| [BOSL](https://github.com/revarbat/BOSL) | Legacy generators; not interchangeable with BOSL2 |
| [MCAD](https://github.com/openscad/MCAD) | Mechanical parts and older generators |
| [NopSCADlib](https://github.com/nophead/NopSCADlib) | Hardware, enclosures, and printable parts |
| [scad-utils](https://github.com/openscad/scad-utils) | List, transformation, and geometry utilities |
| [list-comprehension-demos](https://github.com/openscad/list-comprehension-demos) | Sweep and skin operations; depends on scad-utils |

The wrapper adds their shared parent directory to `OPENSCADPATH`, preserving
any existing entries ahead of the bundle. Normal model-local and user library
lookup still works. Libraries retain their original directory structures and
assets, so includes such as `include <BOSL2/std.scad>` work without copying files
into the home directory. Names and include paths are case-sensitive on Linux.

NopSCADlib's geometry is included, but its separate Python/BOM/documentation
toolchain is not installed by this wrapper.

## Using downloaded generators

Download and extract the complete source project, not just its main SCAD file
or a generated STL. Keep helper files, customizer JSON presets, and imported
assets in their original relative locations.

After rebuilding, open the SCAD file with the Nix-installed OpenSCAD as usual,
through the file manager or File → Open. Both the normal application launcher
and the `openscad` command automatically use the bundled libraries.

In OpenSCAD, show the Customizer panel, adjust the generator's parameters,
preview with F5, render with F6, then export an STL for the slicer. Command-line
exports work through the same wrapper.

## Keeping it available offline

The initial build/download needs network access for anything not already cached.
Rebuild the workstation while online. The installed system generation retains
the engine and its libraries, protecting them from garbage collection.

Opening OpenSCAD then works offline without evaluating the flake or fetching any
inputs. Save the model and all its assets locally too. Installing on a fresh
machine, or rebuilding offline after updates, still requires the necessary
sources and build dependencies to be cached or transferred first.

## When a model still fails

- Start with the first missing `include`/`use` warning; undefined functions or
  empty output are often follow-on errors. OpenSCAD does not resolve or download
  library dependencies automatically.
- An author's private helper library, fonts, images, meshes, and other assets
  are not covered by a general library bundle. Obtain the complete project and
  install the fonts it references; browser-side fonts are not automatically local.
- A generator may require a particular library revision or engine version.
  BOSL v1 and BOSL2 are intentionally installed separately, not aliased.
- Some newer features still need enabling in Preferences → Features, or with
  a CLI flag such as `--enable=textmetrics`, when the model requires them.
- NopSCADlib currently emits `DEPRECATED` notices for some digit-leading names
  with the newer engine. These are upstream compatibility notices, not missing
  dependencies; its smoke render succeeds.
- MakerWorld's website-specific controls/services are not reproduced here;
  only locally executable OpenSCAD source and its available dependencies work.

Add commonly needed libraries to [libraries.nix](libraries.nix), using the
directory name expected by the model and a fixed `rev` and `hash`. For a
generator-specific environment, [default.nix](default.nix) accepts
`extraLibraries` (which can also override bundled names) and `openscadPackage`
(for example, `pkgs.openscad` for the older stable engine). Do not edit files
in the Nix store or silently substitute an unrelated library with the same name.

## Validation

The package exposes its smoke check as `tests.libraries`.
[tests.nix](tests.nix) renders one small STL per library with an isolated home
directory and missing-include/runtime warnings treated as failures. Upstream
deprecation notices are allowed. This checks library discovery and the sweep
library's transitive dependency, not every downloaded generator.