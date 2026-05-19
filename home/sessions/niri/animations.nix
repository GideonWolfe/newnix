# Niri animation configuration, including custom shaders sourced from
# liixini's collection. See ./shaders.nix for the helper that fetches and
# minifies shader source from the `liixini-shaders` flake input.
{ lib, inputs, ... }:
let
  # Wrapped helper that returns { open = name: glslString; close = name: glslString; }
  shaders = import ./shaders.nix { inherit lib inputs; };

  # Default spring used for camera/window motion. The niri wiki recommends
  # keeping `horizontal-view-movement`, `window-movement`, and `window-resize`
  # in sync so that compound animations (e.g. resize-triggered view pans)
  # don't visibly drift:
  #   https://github.com/niri-wm/niri/wiki/Configuration:-Animations#synchronized-animations
  motionSpring = {
    damping-ratio = 1.0;
    stiffness = 800;
    epsilon = 0.0001;
  };
in
{
  # NOTE: liixini's shaders do their own easing internally (sin/cos warps on
  # `niri_clamped_progress`), so use `linear` for the easing curve. Anything
  # else double-eases and produces a chaotic, spasming animation.
  programs.niri.settings.animations = {
    window-open = {
      custom-shader = shaders.open "polar-function";
      kind.easing = {
        duration-ms = 500;
        curve = "linear";
      };
    };

    # Don't want to wait for windows to close
    # window-close = {
    #   custom-shader = shaders.close "perlin";
    #   kind.easing = {
    #     duration-ms = 500;
    #     curve = "linear";
    #   };
    # };

    # Camera-pan animation when focus jumps to an off-screen window or a
    # touchpad swipe releases. A spring reacts to gesture velocity and feels
    # smoother than a fixed-duration easing.
    horizontal-view-movement.kind.spring = motionSpring;
    window-movement.kind.spring = motionSpring;
    window-resize.kind.spring = motionSpring;
  };
}
