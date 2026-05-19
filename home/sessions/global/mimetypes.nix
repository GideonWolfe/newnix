{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

{
  xdg.mimeApps = {

    enable = true;

    defaultApplications = {

      # Web
      "text/html" = [ "firefox.desktop" ];
      "text/xml" = [ "code.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];

      # Archives
      "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-zip-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-freearc" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-bzip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-bzip2" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-xz" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];
      "application/vnd.rar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-iso9660-image" = [ "io.gitlab.adhami3310.Impression.desktop" ];

      "x-scheme-handler/magnet" = [ "transmission-gtk.desktop" ];
      "application/x-bittorent" = [ "transmission-gtk.desktop" ];

      # Directories
      "inode/directory" = lib.mkForce [ "org.gnome.Nautilus.desktop" ];

      # Audio
      "audio/aac" = ["org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/mp3" = ["org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/mpeg" = ["org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/ogg" = ["org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/wav" = ["org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/webm" = ["org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/webp" = ["org.gnome.Decibels.desktop" "vlc.desktop" ];
      "application/x-cdf" = ["org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/midi" = [ "reaper.desktop" ];
      "audio/flac" = [ "org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/x-flac" = [ "org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/opus" = [ "org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/x-wav" = [ "org.gnome.Decibels.desktop" "audacity.desktop" ];
      "audio/x-m4a" = [ "org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/mp4" = [ "org.gnome.Decibels.desktop" "vlc.desktop" ];
      "audio/x-aiff" = [ "audacity.desktop" "org.gnome.Decibels.desktop" ];
      "audio/x-vorbis+ogg" = [ "org.gnome.Decibels.desktop" "vlc.desktop" ];

      # Video 
      "video/mp4" = [ "mpv.desktop" "vlc.desktop" ];
      "video/mpeg" = [ "mpv.desktop" "vlc.desktop" ];
      "video/ogg" = [ "mpv.desktop" "vlc.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" "vlc.desktop" ];
      "video/webm" = [ "mpv.desktop" "vlc.desktop" ];
      "video/quicktime" = [ "mpv.desktop" "vlc.desktop" ];
      "video/x-msvideo" = [ "mpv.desktop" "vlc.desktop" ]; # .avi
      "video/x-flv" = [ "mpv.desktop" "vlc.desktop" ];
      "application/x-matroska" = [ "mpv.desktop" "vlc.desktop" ];
      "application/vnd.kdenlive" = [ "org.kde.kdenlive.desktop" ];

      # Images
      "image/png" = [ "imv.desktop" "org.gnome.Loupe.desktop" ];
      "image/jpeg" = [ "imv.desktop" "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "imv.desktop" "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.inkscape.Inkscape.desktop" "gimp.desktop" ];
      "image/svg+xml-compressed" = [ "org.inkscape.Inkscape.desktop" ];
      "image/tiff" = [ "imv.desktop" "gimp.desktop" ];
      "image/webp" = [ "imv.desktop" "org.gnome.Loupe.desktop" ];
      "image/avif" = [ "imv.desktop" "org.gnome.Loupe.desktop" ];
      "image/heif" = [ "imv.desktop" "org.gnome.Loupe.desktop" ];
      "image/heic" = [ "imv.desktop" "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "imv.desktop" "org.gnome.Loupe.desktop" ];
      "image/x-portable-pixmap" = [ "imv.desktop" ];
      "image/x-xcf" = [ "gimp.desktop" ];
      "image/x-krita" = [ "org.kde.krita.desktop" ];
      "image/openraster" = [ "org.kde.krita.desktop" ];
      "image/x-photoshop" = [ "gimp.desktop" "org.kde.krita.desktop" ];

      # Docs
      "application/pdf" = [ "org.pwmt.zathura.desktop" "org.gnome.Evince.desktop" ];
      "application/postscript" = [ "org.pwmt.zathura-ps.desktop" "org.gnome.Evince.desktop" ];
      "image/vnd.djvu" = [ "org.pwmt.zathura-djvu.desktop" "org.gnome.Evince.desktop" ];
      "application/msword" = [ "writer.desktop" ];
      "application/vnd.ms-excel" = [ "calc.desktop" ]; # .xls
      "application/vnd.ms-powerpoint" = [ "impress.desktop" ]; # .ppt
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ]; # docx
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ]; # pptx
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ]; # .xlsx
      "application/rtf" = [ "writer.desktop" ];
      "application/x-abiword" = [ "writer.desktop" ];

      # All libreoffice file formats
      "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
      "application/vnd.oasis.opendocument.graphics" = [ "draw.desktop" ];
      "application/vnd.oasis.opendocument.formula" = [ "math.desktop" ];

      # LaTeX
      "application/x-tex" = [ "texstudio.desktop" ];
      "text/x-tex" = [ "texstudio.desktop" ];
      "application/x-bibtex" = [ "texstudio.desktop" ];

      # Diagrams
      "application/vnd.jgraph.mxfile" = [ "drawio.desktop" ]; # .drawio
      "application/vnd.gaphor" = [ "org.gaphor.Gaphor.desktop" ];

      # Ebooks
      "application/vnd.amazon.ebook" = [ "com.github.johnfactotum.Foliate.desktop" ];
      "application/epub+zip" = [ "com.github.johnfactotum.Foliate.desktop" ];
      "application/x-mobipocket-ebook" = [ "com.github.johnfactotum.Foliate.desktop" ];
      "application/x-fictionbook+xml" = [ "com.github.johnfactotum.Foliate.desktop" ];

      # Comics / Manga
      "application/x-cbr" = [ "info.febvre.Komikku.desktop" "org.pwmt.zathura-cb.desktop" ];
      "application/x-cbz" = [ "info.febvre.Komikku.desktop" "org.pwmt.zathura-cb.desktop" ];
      "application/vnd.comicbook+zip" = [ "info.febvre.Komikku.desktop" "org.pwmt.zathura-cb.desktop" ];
      "application/vnd.comicbook-rar" = [ "info.febvre.Komikku.desktop" "org.pwmt.zathura-cb.desktop" ];

      #Fonts
      "font/otf" = [ "org.gnome.font-viewer.desktop" ];
      "font/ttf" = [ "org.gnome.font-viewer.desktop" ];
      "font/woff" = [ "org.gnome.font-viewer.desktop" ];
      "font/woff2" = [ "org.gnome.font-viewer.desktop" ];

      # Games / Emulation
      "application/x-gameboy-rom" = [ "skyemu.desktop" ];
      "application/x-gba-rom" = [ "skyemu.desktop" ];
      "application/x-gameboy-color-rom" = [ "skyemu.desktop" ];
      "application/x-nintendo-ds-rom" = [ "skyemu.desktop" ];
      "application/x-n64-rom" = [ "ca.parallel_launcher.ParallelLauncher.desktop" ];
      "application/x-ips-patch" = [ "com.github.Alcaro.Flips.desktop" ];
      "application/x-bps-patch" = [ "com.github.Alcaro.Flips.desktop" ];

      # 3D / CAD / Modeling
      "model/gltf-binary" = [ "f3d.desktop" "blender.desktop" ];
      "model/gltf+json" = [ "f3d.desktop" "blender.desktop" ];
      "model/obj" = [ "f3d.desktop" "blender.desktop" ];
      "model/stl" = [ "f3d.desktop" "OrcaSlicer.desktop" ];
      "application/sla" = [ "f3d.desktop" "OrcaSlicer.desktop" ]; # .stl alt
      "application/vnd.ms-pki.stl" = [ "f3d.desktop" "OrcaSlicer.desktop" ];
      "model/x.stl-binary" = [ "f3d.desktop" "OrcaSlicer.desktop" ];
      "application/x-blender" = [ "blender.desktop" ];
      "application/x-extension-scad" = [ "openscad.desktop" ];

      # Science: Chemistry / Biology
      "chemical/x-pdb" = [ "pymol.desktop" "jmol.desktop" "org.openchemistry.Avogadro2.desktop" ];
      "chemical/x-mdl-molfile" = [ "org.openchemistry.Avogadro2.desktop" "jmol.desktop" ];
      "chemical/x-xyz" = [ "org.openchemistry.Avogadro2.desktop" "jmol.desktop" ];
      "chemical/x-cif" = [ "org.openchemistry.Avogadro2.desktop" "jmol.desktop" ];
      "chemical/x-mol2" = [ "org.openchemistry.Avogadro2.desktop" "pymol.desktop" ];

      # KiCad / Electronics
      "application/x-kicad-project" = [ "org.kicad.kicad.desktop" ];
      "application/x-kicad-schematic" = [ "org.kicad.eeschema.desktop" ];
      "application/x-kicad-pcb" = [ "org.kicad.pcbnew.desktop" ];

      # Text / Code
      "text/css" = ["code.desktop"];
      "text/javascript" = ["code.desktop"];
      "text/json" = ["code.desktop"];
      "text/csv" = ["code.desktop"];
      "text/plain" = [ "org.gnome.gitlab.somas.Apostrophe.desktop" ];
      "text/markdown" = [ "org.gnome.gitlab.somas.Apostrophe.desktop" "code.desktop" ];
      "text/x-markdown" = [ "org.gnome.gitlab.somas.Apostrophe.desktop" "code.desktop" ];
      "application/xml" = [ "code.desktop" ];
      "application/json" = [ "code.desktop" ];
      "application/toml" = [ "code.desktop" ];
      "application/x-yaml" = [ "code.desktop" ];
      "text/yaml" = [ "code.desktop" ];
    };

  };
}
