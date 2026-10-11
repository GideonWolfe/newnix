{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,
  hackrf,
  rtl-sdr,
  soapysdr-with-plugins,
}:
let
  version = "0.6.5";
in
rustPlatform.buildRustPackage {
  pname = "sdrtop";
  inherit version;

  src = fetchFromGitHub {
    owner = "musithang";
    repo = "sdrtop";
    tag = "v${version}";
    hash = "sha256-I0P5PUZLo9nTJU2Va3c3h0mE/C190o7HP6l8n8v3MAo=";
  };

  cargoHash = "sha256-cmArCl6pPrfESgV/TcuWJ8FWoC5D5AFP3koa775MOPI=";

  nativeBuildInputs = [ makeWrapper ];

  # SDR libraries are dlopen'd at runtime, so make the optional backends findable.
  postInstall = ''
    wrapProgram $out/bin/sdrtop \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ hackrf rtl-sdr soapysdr-with-plugins ]}"
  '';

  meta = {
    description = "Terminal bench instrument for SDR hardware: spectrum, waterfall and measurements";
    homepage = "https://github.com/musithang/sdrtop";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sdrtop";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
