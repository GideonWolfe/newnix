{ lib, openscad, runCommand, writeText }:

let
  models = {
    bosl2 = ''
      include <BOSL2/std.scad>
      cuboid([4, 5, 6], rounding=0.5, $fn=16);
    '';
    bosl = ''
      include <BOSL/constants.scad>
      use <BOSL/transforms.scad>
      up(2) cube(2);
    '';
    mcad = ''
      use <MCAD/boxes.scad>
      roundedCube([4, 5, 6], r=0.5, sidesonly=true, center=true, $fn=16);
    '';
    nopscadlib = ''
      include <NopSCADlib/lib.scad>
      washer(M3_washer);
    '';
    scad-utils = ''
      use <scad-utils/lists.scad>
      assert(reverse([1, 2, 3]) == [3, 2, 1]);
      cube(reverse([1, 2, 3]));
    '';
    list-comprehension-demos = ''
      use <list-comprehension-demos/sweep.scad>
      use <scad-utils/transformations.scad>
      sweep(
        [[-1, -1], [-1, 1], [1, 1], [1, -1]],
        [translation([0, 0, 0]), translation([0, 0, 4])]
      );
    '';
  };
in
runCommand "openscad-library-tests" { nativeBuildInputs = [ openscad ]; } ''
  export HOME="$TMPDIR/home"
  export QT_QPA_PLATFORM=offscreen
  unset OPENSCADPATH
  mkdir -p "$HOME" "$out"

  ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: model: ''
    if ! openscad --hardwarnings --export-format asciistl \
      -o "$out/${name}.stl" ${writeText "${name}.scad" model} \
      2> "$out/${name}.log"; then
      cat "$out/${name}.log" >&2
      exit 1
    fi
    if grep -E '^(ERROR|WARNING):' "$out/${name}.log"; then
      exit 1
    fi
    grep -q 'facet normal' "$out/${name}.stl"
  '') models)}
''