{ ... }:

{
  # keyd lets us remap keys at the evdev level, per-device.
  #
  # The Redragon AATROX M811 PRO (SINO WEALTH, USB 258a:002f) sends its side
  # buttons as the plain keyboard keys 1-4, which collide with the real number
  # row. We match only that device and remap them to F13-F16, which nothing
  # else uses, so they can be bound cleanly in the compositor.
  services.keyd = {
    enable = true;
    keyboards.aatrox = {
      ids = [ "258a:002f" ];
      settings.main = {
        "1" = "f13";
        "2" = "f14";
        "3" = "f15";
        "4" = "f16";
        "5" = "f17";
        "6" = "f18";
        "7" = "f19";
        # f20 maps to XF86AudioMute in this XKB keymap and hijacks volume,
        # so button 8 uses f24 (highest F-key, passes through literally).
        "8" = "f24";
      };
    };
  };
}
