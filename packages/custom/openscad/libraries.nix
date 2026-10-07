{ fetchFromGitHub }:

{
  # Directory names must match the case-sensitive include/use paths in models.
  BOSL2 = fetchFromGitHub {
    owner = "BelfrySCAD";
    repo = "BOSL2";
    rev = "e173fa0ae45f9e2082e0d8c0382dae98621b7c20"; # v2.0.766
    hash = "sha256-lTUvzFIvKE9PEtXSwL+9ISdQ4ez0uQ9aMoFV4IklP2U=";
  };

  # BOSL2 is not backwards compatible with BOSL v1.
  BOSL = fetchFromGitHub {
    owner = "revarbat";
    repo = "BOSL";
    rev = "4ce427a8a38786e5f74b728c1e33d9fe7d4904d2";
    hash = "sha256-24vqGt0TPe09K1WTP8fDX2Wx4MlsDnigzx7Ha0mXCOg=";
  };

  MCAD = fetchFromGitHub {
    owner = "openscad";
    repo = "MCAD";
    rev = "bd0a7ba3f042bfbced5ca1894b236cea08904e26";
    hash = "sha256-rnrapCe5BkdibbCYVyGZi0l1/8DZxoDnulK37fwZbqo=";
  };

  NopSCADlib = fetchFromGitHub {
    owner = "nophead";
    repo = "NopSCADlib";
    rev = "00ec2898c0a2cdebd446f0175671b633d5ae7d5f";
    hash = "sha256-F/MgasUtTAVxUEEtSCZnsfPw7Hq7s39tUAUGntyES1A=";
  };

  scad-utils = fetchFromGitHub {
    owner = "openscad";
    repo = "scad-utils";
    rev = "26f8c2cf8124cdafe2fc21f9f9bbf2514e404834";
    hash = "sha256-HjnomGpUQDoyH2L6puiGMyiaBlrxvatHc1rCBJruM6E=";
  };

  list-comprehension-demos = fetchFromGitHub {
    owner = "openscad";
    repo = "list-comprehension-demos";
    rev = "dec3fc3037f0107e5d9da79cb5b36b3e1ad9ce22";
    hash = "sha256-zSFkCXN3wR7v9/xsp7TmURd8f0yoN9oLtWUEE6duoso=";
  };
}