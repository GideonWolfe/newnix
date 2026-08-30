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
  programs.gamemode.enable = true;
}