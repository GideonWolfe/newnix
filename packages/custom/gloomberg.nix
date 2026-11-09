{ lib, stdenv, fetchurl, autoPatchelfHook, }:
let
  version = "0.20.1";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/gloom-sh/gloomberb/releases/download/v${version}/gloomberb-linux-x64.gz";
      hash = "sha256-HawT8rmqeCy6kHd5M4oVCXQw0x+trnSEydz5DmuwUrM=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/gloom-sh/gloomberb/releases/download/v${version}/gloomberb-linux-arm64.gz";
      hash = "sha256-ReWeMBe53y1hAuLhtrDu/oAX4Wh03Q5/A7jYGevOi4o=";
    };
  };
in stdenv.mkDerivation {
  pname = "gloom";
  inherit version;

  src = srcs.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ autoPatchelfHook ];

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    gzip -dc $src > $out/bin/gloom
    chmod +x $out/bin/gloom
    ln -s gloom $out/bin/gloomberb
    runHook postInstall
  '';

  meta = {
    description = "Open-source financial research terminal";
    homepage = "https://github.com/gloom-sh/gloomberb";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "gloom";
    maintainers = [ ];
  };
}
