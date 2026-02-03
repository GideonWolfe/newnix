{ pkgs, lib, stylix, config, ... }:

{
    programs.git.settings.user = {
        name = "GideonWolfe";
        email = "gideon@gideonwolfe.com";
    };
    programs.git.signing.key = "gideon@gideonwolfe.com";
    programs.git.signing.signByDefault = true;
}
