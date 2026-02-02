{ pkgs, lib, config, osConfig, ... }:

{
  programs.newsboat = {
    enable = true;
    autoReload = true;
    reloadTime = 120;
    reloadThreads = 4;
    browser = "xdg-open";

    # Use extraConfig for advanced colors/highlights/bindings not covered by module options
    extraConfig = lib.trim ''
      download-full-page yes
      show-read-feeds yes
      feed-sort-order unreadarticlecount-asc
      text-width 80
      goto-next-feed no

      color info blue default
      color listnormal blue default
      color listnormal_unread cyan default
      color listfocus red default bold
      color listfocus_unread red default bold

      color article cyan default
      color listnormal yellow default

      articlelist-format "%4i %f %D  %?T?|%-17T| ?%t"

      highlight articlelist "^  *[0-9]+  *N  " magenta default

      highlight article "(^Feed:.*|^Title:.*|^Author:.*)" red default
      highlight article "(^Link:.*|^Date:.*)" white default
      highlight article "^Podcast Download URL:.*" cyan default
      highlight article "^Links:" magenta black underline
      highlight article "https?://[^ ]+" green default
      highlight article "^(Title):.*$" blue default
      highlight article "\\[[0-9][0-9]*\\]" magenta default bold
      highlight article "\\[image\\ [0-9]+\\]" green default bold
      highlight article "\\[embedded flash: [0-9][0-9]*\\]" green default bold
      highlight article ":.*\\(link\\)$" cyan default
      highlight article ":.*\\(image\\)$" blue default
      highlight article ":.*\\(embedded flash\\)$" magenta default

      bind-key h quit articlelist
      bind-key h quit article
      bind-key h quit tagselection
      #bind-key h quit feedlist
      bind-key j down feedlist
      bind-key j down tagselection
      bind-key j next articlelist
      bind-key j down article
      bind-key J next-feed articlelist
      bind-key k up feedlist
      bind-key k prev articlelist
      bind-key k up tagselection
      bind-key K prev-feed articlelist
      bind-key k up article
      bind-key l open articlelist
      bind-key l open feedlist
      bind-key l open tagselection

      bind-key G end
      bind-key g home

      bind-key d pagedown
      bind-key u pageup

      ignore-article "*" "title =~ \"Sponsor\""
      ignore-article "*" "title =~ \"Advertisement\""
      ignore-mode "display"
    '';

  };
}
