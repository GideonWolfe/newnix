{
  lib,
  fetchFromGitHub,
  python3Packages,
  meson,
  ninja,
  pkg-config,
  glib,
  gtk4,
  libadwaita,
  blueprint-compiler,
  wrapGAppsHook4,
  appstream-glib,
  desktop-file-utils,
  gobject-introspection,
}:
python3Packages.buildPythonApplication rec {
  pname = "color-code";
  version = "0.2.1";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "oyajun";
    repo = "color-code";
    tag = "v${version}";
    hash = "sha256-eehFaLMubKWwA8jTRvxRMTg67rYBtrfy4llVf/6qF3U=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    blueprint-compiler
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    description =
      "Color Code Calculator for resistors - supports 4, 5 and 6 bands";
    homepage = "https://github.com/oyajun/color-code";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
