{ lib, python3Packages, fetchFromGitHub, tzdata, libnotify }:

python3Packages.buildPythonApplication rec {
  pname = "terrahour";
  version = "1.0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ACoci86";
    repo = "terrahour";
    tag = "v${version}";
    hash = "sha256-RfQHzruqaKuSyKc/hS+/70C+o1i56EN/8WR8sFS1c/o=";
  };

  build-system = with python3Packages; [ setuptools ];

  # Use Nix's timezone tables for offline city and country lookups.
  postPatch = ''
    substituteInPlace terrahour/places.py \
      --replace-fail "/usr/share/zoneinfo/" "${tzdata}/share/zoneinfo/"
  '';

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ libnotify ]}"
    "--set-default TZDIR ${tzdata}/share/zoneinfo"
  ];

  # libc's tzset also needs timezone data inside the build sandbox.
  env.TZDIR = "${tzdata}/share/zoneinfo";
  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  pythonImportsCheck = [ "terrahour.cli" ];

  meta = {
    description = "Terminal world clock with a day/night map and a 24-hour timeline";
    homepage = "https://github.com/ACoci86/terrahour";
    # Application code is MIT; bundled GeoNames data is CC BY 4.0.
    license = with lib.licenses; [ mit cc-by-40 ];
    mainProgram = "terrahour";
    platforms = lib.platforms.linux;
  };
}