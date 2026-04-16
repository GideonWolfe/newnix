{ lib, stdenv, fetchurl, autoPatchelfHook, }:
let
  version = "0.5.1";

  srcs = {
    x86_64-linux = fetchurl {
      url =
        "https://github.com/vincelwt/gloomberb/releases/download/v${version}/gloomberb-linux-x64.gz";
      hash = "sha256-A7Mw4d7otvt3+IhOoTS995P2mSEmGB6CmO7SWfwHTts=";
    };
    aarch64-linux = fetchurl {
      url =
        "https://github.com/vincelwt/gloomberb/releases/download/v${version}/gloomberb-linux-arm64.gz";
      hash = "sha256-6Bxe82ArzenxG9evg7P56aAQYgtUED8mMu/vQqFyaDo=";
    };
  };
in stdenv.mkDerivation {
  pname = "gloomberb";
  inherit version;

  src = srcs.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ autoPatchelfHook ];

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    gzip -dc $src > $out/bin/gloomberb
    chmod +x $out/bin/gloomberb
    runHook postInstall
  '';

  meta = {
    description =
      "Bloomberg-style stock portfolio tracker for the terminal";
    homepage = "https://github.com/vincelwt/gloomberb";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "gloomberb";
    maintainers = [ ];
  };
}
