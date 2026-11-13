{ config, ... }:

with config.lib.stylix.colors.withHashtag;

let
  theme = {
    NAME = "Stylix";
    CTK_APPEARANCE = if config.stylix.polarity == "light" then "light" else "dark";
    PALETTE = {
      BG_DEEP = base00;
      BG_PANEL = base00;
      BG_HEADER = base00;
      BG_ROW = base00;
      BG_ROW_ALT = base01;
      BG_ROW_HOVER = base02;
      BG_LIST = base00;
      BG_SEP = base01;
      BG_HOVER = base02;
      BG_SELECT = base07;
      BG_HOVER_ROW = base02;

      ACCENT = base07;
      ACCENT_HOV = base06;
      TEXT_ON_ACCENT = base00;
      TEXT_MAIN = base05;
      TEXT_DIM = base03;
      TEXT_MUTED = base04;
      TEXT_FAINT = base03;
      TEXT_SEP = base04;
      TEXT_WHITE = base05;
      TEXT_BLACK = base00;
      TEXT_OK = base0B;
      TEXT_ERR = base08;
      TEXT_WARN = base0A;
      TEXT_OK_BRIGHT = base0B;
      TEXT_ERR_BRIGHT = base08;
      TEXT_WARN_BRIGHT = base0A;

      BORDER = base02;
      BORDER_DIM = base02;
      BORDER_FAINT = base03;

      RED_BTN = base08;
      RED_HOV = base08;
      BTN_DANGER = base08;
      BTN_DANGER_HOV = base08;
      BTN_DANGER_ALT = base08;
      BTN_DANGER_ALT_HOV = base0F;
      BTN_DANGER_DEEP = base08;
      BTN_DANGER_DEEP_HOV = base0F;
      BTN_CANCEL = base08;
      BTN_CANCEL_HOV = base0F;

      BTN_SUCCESS = base0B;
      BTN_SUCCESS_HOV = base0C;
      BTN_SUCCESS_ALT = base0B;
      BTN_SUCCESS_ALT_HOV = base0C;
      BTN_SUCCESS_DEEP = base0B;
      BTN_SUCCESS_DEEP_HOV = base0C;

      BTN_WARN = base09;
      BTN_WARN_HOV = base09;
      BTN_WARN_DEEP = base09;
      BTN_WARN_DEEP_HOV = base0A;
      BTN_WARN_BROWN = base09;
      BTN_WARN_BROWN_HOV = base0A;
      BTN_WARN_ORANGE = base09;
      BTN_WARN_ORANGE_HOV = base0A;

      BTN_INFO = base0D;
      BTN_INFO_HOV = base0D;
      BTN_INFO_DEEP = base0D;
      BTN_INFO_DEEP_HOV = base0C;
      BTN_NEUTRAL = base02;
      BTN_NEUTRAL_HOV = base03;
      BTN_GREY = base02;
      BTN_GREY_HOV = base03;
      BTN_GREY_ALT = base01;
      BTN_GREY_ALT_HOV = base02;
      BTN_PURPLE = base0E;
      BTN_PURPLE_HOV = base07;

      TAG_FOLDER = base0C;
      TAG_BSA = base0A;
      TAG_BSA_ALT = base0C;
      TAG_INI_PROFILE = base0C;
      TAG_BUNDLED_FG = base0D;
      TAG_BUNDLED_BG = base01;
      TAG_INSTALLED_BG = base01;
      TAG_UNORDERED_FG = base03;

      TONE_GREEN = base0B;
      TONE_RED = base08;
      TONE_BLUE = base0D;
      TONE_CYAN = base0C;
      TONE_BLUE_SOFT = base07;
      TONE_FLAG = base0A;

      SCROLL_BG = base01;
      SCROLL_TROUGH = base00;
      SCROLL_ACTIVE = base07;

      BG_OVERLAY_ERR = base01;
      BG_OVERLAY_DEEP = base00;
      BG_CARD = base00;
      BG_CARD_ALT = base01;
      BG_GREEN_ROW = base01;
      BG_GREEN_DEEP = base00;
      BG_RED_DEEP = base01;
      BG_ORANGE_DEEP = base01;
      BG_GREEN_TEXT = base0B;
      BG_RED_TEXT = base08;
      BG_ORANGE_TEXT = base0A;
      BG_BLUE_DEEP = base01;
      BG_BLUE_TEXT = base0D;
      BG_DARK_BLUE = base00;
      BG_DARK_GREEN = base00;
      BG_ENTRY = base00;
      BG_BTN_SAVE = base0D;
      BG_SELECT_BAR = base02;
      BG_MOD_REQ = base0B;
      BG_MOD_OPT = base09;

      STATUS_ERR_BRIGHT = base08;
      STATUS_BADGE_RED = base08;
      STATUS_BADGE_GREEN = base0B;
      STATUS_SUCCESS_SOLID = base0B;
      STATUS_QUEUED = base09;
      STATUS_DL_GREEN = base0C;

      TEXT_CARD = base05;
      TEXT_CARD_DIM = base03;
      TEXT_CARD_MED = base04;
      TEXT_TREE_FG = base0B;

      CTK_TEXT = [ base05 base05 ];
      CTK_FOOTER_FG = [ base00 base00 ];
      CTK_FOOTER_HOV = [ base01 base01 ];
      CTK_SEP = [ base02 base02 ];
      CTK_SEP_ALT = [ base03 base03 ];
      CTK_BTN_HOVER = [ base01 base01 ];

      DROPDOWN_ARROW = base07;
      LINK_BLUE = base0C;

      PLUGIN_CYCLE_ERR_BG = base01;
      PLUGIN_CYCLE_ERR_FG = base08;
      PLUGIN_CYCLE_OK_BG = base01;
      PLUGIN_CYCLE_OK_FG = base0B;
      PLUGIN_CYCLE_WARN_BG = base01;
      PLUGIN_CYCLE_WARN_FG = base0A;
      PLUGIN_CYCLE_ANCHOR = base09;
      PLUGIN_CYCLE_LINK = base0C;

      FILE_WIN = base0B;
      FILE_LOSE = base08;
      FILE_DIM = base03;
      FILE_ANCHOR = base09;
      HIGHLIGHT_DRAG = base0D;

      CONFLICT_HL_WIN = base02;
      CONFLICT_HL_LOSE = base02;
      CONFLICT_HL_ANCHOR = base02;
      REQ_HL_REQUIRES = base02;
      REQ_HL_REQUIRED_BY = base02;

      FRAMEWORK_INSTALLED_BG = base01;
      FRAMEWORK_INSTALLED_FG = base0B;
      FRAMEWORK_STAGED_BG = base01;
      FRAMEWORK_STAGED_FG = base0A;
      FRAMEWORK_DISABLED_BG = base01;
      FRAMEWORK_DISABLED_FG = base0D;
      FRAMEWORK_MISSING_BG = base01;
      FRAMEWORK_MISSING_FG = base08;

      OVERWRITE_SEP_BG = base00;
      OVERWRITE_SEP_FG = base0B;
      ROOT_SEP_BG = base00;
      ROOT_SEP_FG = base0D;
      CHECK_FILL = base07;
    };
  };
in
{
  xdg.configFile."AmethystModManager/themes/stylix.json".text =
    builtins.toJSON theme;
}
