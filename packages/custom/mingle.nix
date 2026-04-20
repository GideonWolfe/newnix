{
  lib,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  vala,
  glib,
  gtk4,
  libadwaita,
  json-glib,
  libsoup_3,
  libgee,
  blueprint-compiler,
  wrapGAppsHook4,
  appstream-glib,
  desktop-file-utils,
  gobject-introspection,
  glib-networking,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "mingle";
  version = "0.30";

  src = fetchFromGitHub {
    owner = "halfmexican";
    repo = "mingle";
    tag = "v${version}";
    hash = "sha256-heAEFCXY3KKJac8BKRIX+hfP7PyPW8l7NmugzbvfzPE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
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
    json-glib
    libsoup_3
    libgee
    glib-networking
  ];

  meta = {
    description =
      "A GTK4 app to combine emojis using Google's Emoji Kitchen";
    homepage = "https://github.com/halfmexican/mingle";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
