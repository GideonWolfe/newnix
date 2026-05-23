{ pkgs, lib, stylix, config, ... }:

{
    programs.git.settings.user = {
        name = "GideonWolfe";
        email = "gideon@gideonwolfe.com";
    };
    programs.git.signing.key = "gideon@gideonwolfe.com";
    programs.git.signing.signByDefault = true;

    # Fetch public GitHub repos anonymously over HTTPS, but transparently
    # rewrite push URLs to use the `github:` SSH alias (YubiKey-backed).
    #
    # Why: pulls/fetches don't need auth for public repos, so requiring the
    # YubiKey just to `git pull` on a remote host (e.g. hades over SSH) is
    # unnecessary friction. Pushing still requires the key, which is correct.
    programs.git.settings."url \"github:\"".pushInsteadOf = "https://github.com/";
}
