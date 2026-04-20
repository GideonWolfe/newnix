{
  lib,
  fetchFromGitHub,
  nodejs,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "periodic-table-cli";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "spirometaxas";
    repo = "periodic-table-cli";
    tag = "v${version}";
    hash = "sha256-0b6JQWIH9BpfpeMDlsnxwsg1ai4xyCosmIphtYdTR5E=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/periodic-table-cli/src $out/bin
    cp -r src/* $out/lib/periodic-table-cli/src/
    cp package.json $out/lib/periodic-table-cli/

    cat > $out/bin/periodic-table-cli <<EOF
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/periodic-table-cli/src/cli.js "\$@"
    EOF
    chmod +x $out/bin/periodic-table-cli

    runHook postInstall
  '';

  meta = {
    description =
      "An interactive Periodic Table of Elements app for the console";
    homepage = "https://github.com/spirometaxas/periodic-table-cli";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
