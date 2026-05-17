# Helper for using liixini's GLSL shader collection
# (https://github.com/liixini/shaders) with niri-flake's `custom-shader` option.
#
# Usage from niri.nix:
#
#   let
#     shaders = import ./shaders.nix { inherit lib inputs; };
#   in {
#     programs.niri.settings.animations = {
#       window-open.custom-shader  = shaders.open  "bounce";
#       window-close.custom-shader = shaders.close "bounce";
#     };
#   }
#
# Why minify?
#   niri-flake serialises `custom-shader` as a regular KDL string (with `\n`
#   escapes for newlines), not as a raw `r"..."` string. In practice niri can
#   choke on the resulting multi-line blob, so we strip comments and collapse
#   whitespace at eval time. The result is a single-line ASCII GLSL string
#   that needs no escaping, making niri-flake's plain `"..."` quoting
#   equivalent to a `r"..."` raw string in KDL.
#
# Available shader names (each is a directory in the upstream repo containing
# `open.glsl` and `close.glsl`):
#   bounce, circle, colour-distance, crazy-parametric, crosshatch, crosswarp,
#   directional, directional-wipe, dissolve, fade, fadecolor, flyeye,
#   glass-warp, glitch, heat-melt, ink-splash, inkwell-drop, morph,
#   overexposure, perlin, pixelate, pixelfade-wave, plasma-flow,
#   polar-function, polka-dots-curtain, randomsquares, ripple, smoke, snap,
#   soft-warp-fade, static-fade, voronoi-shatter, wave-warp
{ lib, inputs }:

let
  # Root of the fetched shader repo (pinned via flake.lock).
  shaderRoot = inputs.liixini-shaders;

  # Split `s` on every match of regex `re` and discard the matches, keeping
  # only the literal segments. `builtins.split` returns alternating strings
  # and match-lists; we want just the strings.
  stripRe = re: s:
    lib.concatStrings
      (builtins.filter builtins.isString (builtins.split re s));

  # Collapse comments and whitespace so the shader is one line of GLSL.
  minify = src: let
    noBlock = stripRe ''/\*[^*]*\*+([^/*][^*]*\*+)*/'' src;
    noLine  = stripRe "//[^\n]*" noBlock;
  in
    builtins.concatStringsSep " "
      (builtins.filter (x: x != "")
        (builtins.filter builtins.isString
          (builtins.split "[[:space:]]+" noLine)));

  # Read a shader of a given kind ("open" / "close") for the named effect.
  # Fails fast with a readable error if the file is missing.
  read = kind: name: let
    p = "${shaderRoot}/${name}/${kind}.glsl";
  in
    if builtins.pathExists p
    then minify (builtins.readFile p)
    else throw "liixini shader not found: ${name}/${kind}.glsl";
in {
  open  = read "open";
  close = read "close";
}
