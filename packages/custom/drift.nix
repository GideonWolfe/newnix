{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  version = "1.0.1";
in
buildGoModule {
  pname = "drift";
  inherit version;

  src = fetchFromGitHub {
    owner = "phlx0";
    repo = "drift";
    tag = "v${version}";
    hash = "sha256-DzP9dOx28c6y9M8r9qYzsBbJwy8tTnTmLdEDoYS1btU=";
  };

  vendorHash = "sha256-FsNa9qp2MnPk1onv/O13mFi+82yP7D4LdILZsNzHs+4=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description =
      "Terminal screensaver that activates when you're idle — constellations, rain, particles & more";
    homepage = "https://github.com/phlx0/drift";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}