{ lib, stdenvNoCC, fetchFromGitHub, python3, qt6, makeDesktopItem, copyDesktopItems, }:
let
  pythonEnv = python3.withPackages (ps:
    with ps; [
      numpy
      pillow
      platformdirs
      pyserial
      pyside6
      pyqtgraph
    ]);
in stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "qttinysa";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "g4ixt";
    repo = "QtTinySA";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3Z6Xm/KPHJp1Jz5nmcKD/GsNgR5XWN7aksCVz4+TQyY=";
  };

  nativeBuildInputs = [ qt6.wrapQtAppsHook copyDesktopItems ];
  buildInputs = [ pythonEnv qt6.qtbase ];

  dontConfigure = true;
  dontBuild = true;

  desktopItems = [
    (makeDesktopItem {
      name = "qttinysa";
      desktopName = "QtTinySA";
      comment = "GUI for the TinySA and TinySA Ultra spectrum analysers";
      exec = "qttinysa";
      icon = "qttinysa";
      categories = [ "Science" "HamRadio" "Utility" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/qttinysa
    cp -r src/* $out/share/qttinysa/

    install -Dm644 src/tinySAsmall.png \
      $out/share/icons/hicolor/48x48/apps/qttinysa.png

    makeQtWrapper ${pythonEnv}/bin/python $out/bin/qttinysa \
      --add-flags "$out/share/qttinysa/QtTinySA.py"

    runHook postInstall
  '';

  meta = {
    description =
      "Python TinySA / TinySA Ultra spectrum analyser GUI using Qt and PySide6";
    homepage = "https://github.com/g4ixt/QtTinySA";
    license = lib.licenses.gpl3Plus;
    mainProgram = "qttinysa";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
})
