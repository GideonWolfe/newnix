{ inputs, lib, ... }:
# Home Manager role for all my non-necessary configs and themes
{
  imports =
    lib.optional (inputs ? spicetify-nix) inputs.spicetify-nix.homeManagerModules.default
    ++ [

    ###########################
    # Themed applications etc. #
    ###########################
    ../apps/imv/imv.nix
    ../apps/zathura/zathura.nix
    ../apps/foliate/foliate.nix
    ../apps/halloy/halloy.nix
    ../apps/gnuplot/gnuplot.nix
    ../apps/cava/cava.nix
    ../apps/cavalier/cavalier.nix
    ../apps/newsboat/newsboat.nix
    ../apps/spicetify/spicetify.nix
    ../apps/fastfetch/fastfetch.nix
    ../apps/vscode/vscode.nix
    ../apps/blender/blender-theme.nix
    ../apps/obsidian/obsidian-stylix-css.nix
    ../apps/element/element.nix
    ../apps/ghidra/ghidra.nix
    ../apps/git/git.nix
    ../apps/gh/gh.nix
    ../apps/kicad/kicad.nix
    ../apps/mpv/mpv.nix
    ../apps/libreoffice/libreoffice.nix
    ../apps/blockbench/blockbench.nix
    ../apps/minimeters/minimeters.nix
    ../apps/godot/godot-theme.nix
    ../apps/astrolog/astrolog.nix
    ../apps/shortwave/shortwave.nix
    ../apps/sdrpp/sdrpp.nix
    ../apps/hackernews-tui/hackernews-tui.nix
    ../apps/sourcegit/sourcegit.nix
    ../apps/xyosc/xyosc.nix
    ../apps/vesktop/vesktop.nix
    ../apps/freetube/freetube.nix
    ../apps/kdeconnect/kdeconnect.nix
    ../apps/kube/kube.nix
    ../apps/chromium/chromium.nix
    ../apps/firefox/firefox.nix
    ../apps/darkreader/darkreader.nix
    ../apps/startpage/service.nix
    ../apps/thunderbird/thunderbird.nix
    ../apps/neomutt/neomutt.nix
    ../apps/gpredict/gpredict.nix
    ../apps/obs-studio/obs-theme.nix
    ../apps/aichat/aichat.nix
    ../apps/mods/mods.nix
    ../apps/f3d/f3d.nix
    ../apps/flameshot/flameshot.nix
    ../apps/fzf/fzf.nix
    ../apps/glava/rc.nix
    ../apps/glava/shaders.nix
    ../apps/vdirsyncer/vdirsyncer.nix
    ../apps/khard/khard.nix
    ../apps/khal/khal.nix
    ../apps/calcure/calcure.nix
  ];
}
