{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl, }:
let version = "v0.3.0";
in rustPlatform.buildRustPackage {
  pname = "proteinview";
  inherit version;

  src = fetchFromGitHub {
    owner = "001TMF";
    repo = "ProteinView";
    tag = version;
    hash = "sha256-GH5+X6VjDdFy3SFPuEHsZ5iWMSPJGjzeXcPXL26IFg0=";
  };

  cargoHash = "sha256-x2qnUd1Lt5qpugETuR7ET+eDJ7jzub9O6BMBQxbIlVE=";

  buildFeatures = [ "fetch" ];


  # bug with current release, this file isn't committed
  checkFlags = [ "--skip" "parser::pdb::tests::test_nmr_multimodel_loads_single_model" ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = {
    description =
      "Terminal protein structure viewer — interactive 3D visualization of PDB/mmCIF structures";
    homepage = "https://github.com/001TMF/ProteinView";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
