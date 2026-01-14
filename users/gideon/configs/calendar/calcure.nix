{ lib, config, ... }:

{
  # Appends my specific calendar events location to the pre-existing calcure theme/settings
  xdg.configFile.calcure.text = lib.mkAfter ''
      ics_event_files = ${config.accounts.calendar.basePath}gmail/${config.accounts.calendar.accounts.gmail.primaryCollection}

  '';
}
