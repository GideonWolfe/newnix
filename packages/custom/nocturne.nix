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
  libsecret,
  gst_all_1,
  blueprint-compiler,
  wrapGAppsHook4,
  appstream-glib,
  desktop-file-utils,
  gobject-introspection,
}:
python3Packages.buildPythonApplication rec {
  pname = "nocturne";
  version = "0.9.7";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "Jeffser";
    repo = "Nocturne";
    tag = version;
    hash = "sha256-lMR2KFLROlZ9kqtMO9ZhDqZj96hhZJFzXtqGJpk5/N4=";
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
    libsecret
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    requests
    mutagen
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    description =
      "An Adwaita music player and library manager for Navidrome and Jellyfin";
    homepage = "https://github.com/Jeffser/Nocturne";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
