{ world }:
let
  bookmarks = import ./bookmarks.nix { inherit world; };
in
{
  server = {
    host = "127.0.0.1";
    port = 8086;
  };

  branding = {
    app-name = "Dashboard";
    logo-text = "GW";
  };

  pages = [
    {
      name = "Home";
      width = "wide";
      columns = [
        {
          size = "small";
          widgets = [ bookmarks.web ];
        }
        {
          size = "full";
          widgets = [ bookmarks.applications bookmarks.media ];
        }
        {
          size = "small";
          widgets = [ bookmarks.infrastructure ];
        }
      ];
    }
  ];
}