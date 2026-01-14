{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [

    #########
    # PHOTO #
    #########
    pkgs.exif # manipulate photo metadata
    pkgs.exiftool # manipulate photo metadata
    #pkgs.kgeotag # standalone geotag editor/viewer #BUG: fails bc marble wont buld
    pkgs.photini # GUI for viewing/editing photo metadata
    pkgs.gifsicle # manipulate gif metadata
    pkgs.gimp
    pkgs.gnome-frog # OCR tool
    pkgs.gImageReader # Simple Gtk/Qt front-end to tesseract-ocr
    pkgs.upscayl # local AI image upscaler
    pkgs.upscaler # local GNOME image upscaler
    pkgs.loupe # gnome-image-viewer GUI for light editing and viewing

  ];
}
