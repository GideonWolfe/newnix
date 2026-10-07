{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  desktop-file-utils,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  libsoup_3,
  udev,
  webkitgtk_4_1,
}:
stdenv.mkDerivation rec {
  pname = "betaflight-app";
  version = "2026.6.2";

  # The native Tauri app replaces nixpkgs' legacy NW.js Configurator 10.10.0.
  src = fetchurl {
    url = "https://github.com/betaflight/betaflight-configurator/releases/download/${version}/Betaflight-${version}-amd64.deb";
    hash = "sha256-wnuy4bt6Dp/wEAjRPKtHsEXm0QUPJt18NF9Nm4E1ZX4=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    dbus
    gdk-pixbuf
    glib
    gsettings-desktop-schemas
    # WebKit needs appsink and media plugins discoverable through the GTK wrapper.
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gtk3
    libsoup_3
    stdenv.cc.cc.lib
    udev
    webkitgtk_4_1
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" source
    runHook postUnpack
  '';
  sourceRoot = "source";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r usr/bin usr/share "$out/"
    substituteInPlace "$out/share/applications/Betaflight.desktop" \
      --replace-fail 'Exec=betaflight-app' "Exec=$out/bin/betaflight-app"
    runHook postInstall
  '';

  # Create the compatibility alias after GTK wrapping so both commands use it.
  postFixup = ''
    ln -s betaflight-app "$out/bin/betaflight-configurator"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ desktop-file-utils ];
  installCheckPhase = ''
    runHook preInstallCheck
    desktop-file-validate "$out/share/applications/Betaflight.desktop"
    test -x "$out/bin/betaflight-app"
    test -x "$out/bin/betaflight-configurator"
    test -f "$out/share/icons/hicolor/128x128/apps/betaflight-app.png"
    runHook postInstallCheck
  '';

  meta = {
    description = "Native configuration app for Betaflight flight controllers";
    homepage = "https://betaflight.com/docs/wiki/app";
    license = lib.licenses.gpl3;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "betaflight-app";
  };
}