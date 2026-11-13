{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "terrascope";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "a-shygun";
    repo = "Terrascope";
    tag = "v${version}";
    hash = "sha256-emrWNgaGbsAbm3ZMTMnbgcNlFzUU/a+4O7jMIRRx/8k=";
  };

  build-system = with python3Packages; [ hatchling ];
  dependencies = with python3Packages; [ numpy pillow pyyaml pyshp ];

  pythonImportsCheck = [ "terrascope" "terrascope.core.cli" ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/terrascope-home"
    mkdir -p "$HOME"
    "$out/bin/terrascope" --version | grep -Fx "terrascope ${version}"
    "$out/bin/terrascope" --help > /dev/null
    test -s "$out/${python3Packages.python.sitePackages}/terrascope/assets/reference_data.json"
    runHook postInstallCheck
  '';

  meta = {
    description = "Braille terminal world map with live weather, aircraft, and earthquake layers";
    homepage = "https://github.com/a-shygun/Terrascope";
    license = lib.licenses.mit;
    mainProgram = "terrascope";
    platforms = lib.platforms.unix;
  };
}
