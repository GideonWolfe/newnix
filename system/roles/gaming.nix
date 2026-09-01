# This role is used for any system where we are gaming
{
  imports = [

    ###########
    # Modules #
    ###########
    # Steam, of course    
    ../modules/services/gaming/steam.nix

    ############
    # Packages #
    ############
    # Gaming packages
    ../../packages/gaming/gaming.nix 
  ];

  # GameMode bumps the CPU governor to `performance` and raises process priority
  # while a game runs. Without it, laptops idle in the `powersave` governor and
  # games stutter. Use with the `gamemoderun %command%` Steam launch option
  # (combine with offload: `gamemoderun nvidia-offload %command%`).
  programs.gamemode = {
    enable = true;
    settings.general = {
      # Switch power-profiles-daemon to `performance` while a game runs (and
      # restore afterwards). On the XPS 15 the `quiet`/`balanced` platform
      # profile caps the RTX 3050 to 20W (half its 40W budget), pinning clocks
      # at ~232MHz and causing ~30fps; `performance` unlocks the full 40W.
      desiredgov = "performance";
      desiredprof = "performance";
    };
  };
}