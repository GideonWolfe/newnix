{
  lib,
  callPackage,
  fetchFromGitHub,
  linkFarm,
  makeWrapper,
  symlinkJoin,
  openscad-unstable,
  openscadPackage ? openscad-unstable,
  extraLibraries ? { },
}:

let
  librarySources = (import ./libraries.nix { inherit fetchFromGitHub; }) // extraLibraries;
  libraries = linkFarm "openscad-libraries" (
    lib.mapAttrsToList (name: path: { inherit name path; }) librarySources
  );

  package = symlinkJoin {
    name = "openscad-with-libraries-${openscadPackage.version}";
    paths = [ openscadPackage ];
    nativeBuildInputs = [ makeWrapper ];

    postBuild = ''
      rm "$out/bin/openscad"
      makeWrapper ${lib.getExe openscadPackage} "$out/bin/openscad" \
        --suffix OPENSCADPATH : ${libraries}

      # Desktop launches must use the same library-aware wrapper as the CLI.
      rm "$out/share/applications/openscad.desktop"
      substitute ${openscadPackage}/share/applications/openscad.desktop \
        "$out/share/applications/openscad.desktop" \
        --replace-fail 'Exec=openscad %f' "Exec=$out/bin/openscad %f"
    '';

    passthru = {
      inherit libraries librarySources openscadPackage;
      tests.libraries = callPackage ./tests.nix { openscad = package; };
    };

    meta = openscadPackage.meta // {
      description = "OpenSCAD with pinned libraries for offline model generators";
    };
  };
in
package