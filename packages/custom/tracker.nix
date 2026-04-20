{
  lib,
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config,
  makeWrapper,
  cacert,
}:
let
  version = "0.1.18";
in
rustPlatform.buildRustPackage {
  pname = "tracker";
  inherit version;

  src = fetchFromGitHub {
    owner = "ShenMian";
    repo = "tracker";
    tag = "v${version}";
    hash = "sha256-RzwTYPVHGXbSeP6i5laRz9u5CBJY3MHF/Qmm8IZ5wRc=";
  };

  cargoHash = "sha256-1E0SH5RZY0i6hUqK29gCjIA65HrHXl9pstjMvTI0F+Y=";

  nativeBuildInputs = [ pkg-config makeWrapper ];
  buildInputs = [ openssl ];

  postInstall = ''
    wrapProgram $out/bin/tracker \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set SSL_CERT_DIR "${cacert}/etc/ssl/certs"
  '';

  meta = {
    description =
      "Terminal-based real-time satellite tracking and orbit prediction";
    homepage = "https://github.com/ShenMian/tracker";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
