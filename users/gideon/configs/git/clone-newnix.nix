{ pkgs, lib, config, ... }:

let
  # Where the repo should live and which remote to use.
  repoDir = "${config.home.homeDirectory}/newnix";
  # Use the `github:` SSH alias (YubiKey-backed) so pushes work out of the box.
  repoUrl = "github:gideonwolfe/newnix.git";
in
{
  # First-time clone of my nix config. Runs on every activation but is a no-op
  # once the repo exists, so it only actually clones on a fresh machine.
  home.activation.cloneNewnix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${repoDir}/.git" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone "${repoUrl}" "${repoDir}"
    else
      # Make sure origin points at the SSH alias even if it was cloned over HTTPS.
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "${repoDir}" remote set-url origin "${repoUrl}"
    fi
  '';
}
