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
      head-widgets = [ (import ./widgets/gatus-monitor.nix { inherit world; }) ];
      columns = [
        {
          size = "small";
          widgets = [
            bookmarks.web
            {
              type = "search";
              search-engine = "duckduckgo";
              bangs = [
                {
                  title = "Nix Search";
                  shortcut = "!n";
                  url = "https://nixsearch.thekoppe.com/?q={QUERY}";
                }
              ];
            }
          ];
        }
        {
          size = "full";
          widgets = [ bookmarks.applications ];
        }
        {
          size = "small";
          widgets = [ bookmarks.infrastructure ];
        }
      ];
    }
  ];
}