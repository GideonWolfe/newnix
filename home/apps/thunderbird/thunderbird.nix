{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

{
  programs.thunderbird = {
    # individual accounts can be enabled at the accounts.email config level for HM
    enable = true;

    profiles = {
      "gideon" = {
        #name = "default";
        isDefault = true;

        withExternalGnupg = true;

        settings = {
          # Enable userChrome customizations
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # Allow remote images to be loaded
          "mailnews.message_display.disable_remote_image" = false;

          # Main app color
          "browser.display.background_color" = "${base00}";
          "browser.display.foreground_color" = "${base05}";
          # Force for all messages
          "browser.display.document_color_use" = 2;

          # Compose view colors
          "msgcompose.background_color" = "${base01}";
          "msgcompose.text_color" = "${base05}";

          # Link colors
          "layout.css.visited_links_enabled" = true;
          "browser.visited_color" = "${base0E}";
          "reader.custom_colors.visited-links" = "${base0E}";
          "reader.custom_colors.unvisited-links" = "${base0D}";
          "browser.anchor_color" = "${base0D}";
          "browser.anchor_color.dark" = "${base0E}";

          "font.name.sans-serif.x-western" =
            "${config.stylix.fonts.serif.name}";

          # Color of important tag in mail
          "mailnews.tags.$label1.color" = "${base08}";
          # Work tag
          "mailnews.tags.$label2.color" = "${base09}";
          # Personal tag
          "mailnews.tags.$label3.color" = "${base0B}";
          # To Do Tag
          "mailnews.tags.$label4.color" = "${base0D}";
          # Later Tag
          "mailnews.tags.$label5.color" = "${base0E}";

          # BUG: not working so great
          "mail.openpgp.allow_external_gnupg" = true;
          "mail.openpgp.fetch_pubkeys_from_gnupg" = true;
        };

        userChrome = ''
          :root {
            --bg-color: ${base01} !important;
            --text-color: ${base05} !important;
            --title-color: ${base0D} !important;
            --primary-color: ${base0D} !important;
            --primary-color-hover: ${base0B} !important;
            --btn-color: ${base05} !important;
            --button-background-color: ${base01} !important;
            --button-border-color: ${base02} !important;
            --button-hover-background-color: ${base02} !important;
            --button-active-background-color: ${base02} !important;
            --button-border-radius: 6px !important;
            --btn-bg: ${base01} !important;
            --btn-bg-hover: ${base00} !important;
            --popup-bg: ${base02} !important;
            --primary: ${base0D} !important;
            --layout-background-0: ${base00} !important;
            --layout-background-1: ${base01} !important;
            --layout-background-2: ${base01} !important;
            --layout-background-3: ${base01} !important;
            --layout-background-4: ${base02} !important;
            --layout-border-0: ${base02} !important;
            --layout-border-1: ${base02} !important;
            --layout-border-2: ${base03} !important;
            --layout-color-1: ${base05} !important;
            --layout-color-2: ${base04} !important;
            --toolbar-background-color: ${base01} !important;
            --toolbar-text-color: ${base05} !important;
            --toolbar-field-background-color: ${base00} !important;
            --toolbar-field-background-color-focus: ${base00} !important;
            --toolbar-field-color: ${base05} !important;
            --toolbar-field-text-color-focus: ${base05} !important;
            --toolbar-field-border-color: ${base02} !important;
            --toolbar-field-focus-border-color: ${base0D} !important;
            --focus-outline-color: ${base0D} !important;
            --spaces-bg-color: ${base01} !important;
            --sidebar-background: ${base01} !important;
            --foldertree-background: ${base00} !important;
            --text-color-error: ${base08} !important;
            --text-color-deemphasized: ${base04} !important;
            --error-text-color: ${base08} !important;
            --selected-item-color: ${base0D} !important;
            --selected-item-text-color: ${base00} !important;
            --folderpane-unread-count-text: ${base00} !important;
            --folderpane-unread-new-count-background: ${base0A} !important;
            --folderpane-unread-count-background: ${base0B} !important;
            --icon-color: ${base0D} !important;
            --new-folder-color: ${base0B} !important;
            --folder-color-inbox: ${base0D} !important;
            --folder-color-draft: ${base0E} !important;
            --folder-color-sent: ${base0B} !important;
            --folder-color-archive: ${base0F} !important;
            --folder-color-spam: ${base08} !important;
            --folder-color-trash: ${base04} !important;
            --folder-color-template: ${base03} !important;
            --folder-color-newsletter: ${base0C} !important;
            --folder-color-rss: ${base09} !important;
            --folder-color-outbox: ${base0C} !important;
            --folder-color-folder: ${base0A} !important;
            --folder-color-folder-filter: ${base07} !important;
            --folder-color-folder-rss: ${base09} !important;

            --tabs-toolbar-background-color: ${base00} !important;

            --tree-view-bg: ${base00} !important;
            --tree-view-color: ${base05} !important;
            --tree-header-bg: ${base01} !important;
            --thread-pane-spam-fill: ${base00} !important;
            --thread-pane-spam-stroke: ${base08} !important;
            --thread-pane-unread-fill: ${base00} !important;
            --thread-pane-unread-stroke: ${base0B} !important;

            --tree-card-background: ${base00} !important;
            --tree-card-background-selected-current: ${base01} !important;
            --tree-card-background-selected: ${base01} !important;
            --tree-card-background-current-spam: ${base00} !important;
            --tree-card-background-selected-current-spam: ${base00} !important;
            --tree-card-border-hover-spam: ${base08} !important;
            --tree-card-border-selected-spam: ${base08} !important;

            --indicator-border-selected-spam: ${base08} !important;
            --indicator-background-selected-spam: ${base08} !important;

            --tree-card-border: ${base03} !important;
            --tree-card-border-focus: ${base0E} !important;
            --tree-card-border-hover: ${base0B} !important;
            --treeitem-text-active: ${base0E} !important;
            --treeitem-background-selected: ${base01} !important;
            --read-status-fill: transparent !important;
            --read-status-stroke: ${base0D} !important;

            --list-indicator-background-selected-focused: ${base0A} !important;
            --list-indicator-background-selected-current: ${base09} !important;



            --thread-pane-flag-fill: ${base0A} !important;
            --thread-pane-flag-stroke: ${base0A} !important;


            --search-bar-border-color: ${base02} !important;
            --search-focus-outline-color: ${base0D} !important;

            --viewColor: ${base05} !important;
            --viewBackground: ${base00} !important;
            --viewBorderColor: ${base02} !important;
            --viewCalendarHeaderBackground: ${base01} !important;
            --viewTodayColor: ${base05} !important;
            --viewTodayBackground: color-mix(in srgb, ${base0D} 6%, ${base00}) !important;
            --viewTodayOffBackground: color-mix(in srgb, ${base0D} 6%, ${base01}) !important;
            --viewTodayWeekendBackground: color-mix(in srgb, ${base0D} 6%, ${base01}) !important;
            --viewTodayLabelColor: ${base00} !important;
            --viewTodayLabelBackground: ${base0D} !important;
            --viewTodayDayLabelBackground: color-mix(in srgb, ${base0D} 12%, ${base00}) !important;
            --viewWeekendBackground: ${base01} !important;
            --viewOffTimeBackground: ${base01} !important;
            --viewMonthOtherBackground: ${base01} !important;
            --viewMonthDayOtherBackground: ${base01} !important;
            --viewMonthWeekLabelBackground: ${base02} !important;
            --viewMonthDayOffLabelBackground: ${base01} !important;
            --viewTimeBoxColor: ${base04} !important;
            --viewDayLabelSelectedColor: ${base00} !important;
            --viewDayLabelSelectedBackground: ${base0D} !important;
            --calendar-view-toggle-background: ${base00} !important;
            --calendar-view-toggle-border-color: ${base02} !important;
            --calendar-view-toggle-selected-background: ${base02} !important;
            --calendar-view-toggle-selected-hover-background: ${base02} !important;
            --calendar-view-toggle-shadow-color: transparent !important;
          }

          #navigation-toolbox {
            background-color: ${base01} !important;
            background-image: none !important;
            color: ${base05} !important;
          }

          /* These tokens are defined on the widget, not inherited from :root. */
          calendar-minimonth {
            --mmMainBackground: ${base01} !important;
            --mmMainBorderColor: ${base02} !important;
            --mmBoxBackground: ${base00} !important;
            --mmBoxBorderColor: ${base02} !important;
            --mmBoxItemColor: ${base05} !important;
            --mmHighlightColor: ${base00} !important;
            --mmHighlightBackground: ${base0D} !important;
            --mmHighlightBorderColor: ${base0D} !important;
            --mmDayColor: ${base05} !important;
            --mmDayOtherColor: ${base04} !important;
            --mmDayWeekColor: ${base04} !important;
            --mmDayTodayColor: ${base0D} !important;
            --mmDayTodayBackground: color-mix(in srgb, ${base0D} 12%, ${base01}) !important;
            --mmDayTodayBorderColor: ${base0D} !important;
            --mmDaySelectedColor: ${base00} !important;
            --mmDaySelectedBackground: ${base0D} !important;
            --mmDaySelectedBorderColor: ${base0D} !important;
            --mmDaySelectedTodayBackground: ${base0D} !important;
            --mmDaySelectedTodayBorderColor: ${base0D} !important;
            --mmDayBusyColor: ${base0D} !important;
            border: 1px solid var(--mmMainBorderColor) !important;
            border-radius: 8px !important;
            padding: 6px !important;
          }

          #unifinder-searchBox,
          #unifinder-search-results-tree treecol {
            background-color: ${base01} !important;
            color: ${base05} !important;
            border-color: ${base02} !important;
          }

          #unifinder-search-field,
          #unifinder-searchBox menulist {
            background-color: ${base00} !important;
            color: ${base05} !important;
            border: 1px solid ${base02} !important;
            border-radius: 6px !important;
          }

          #unifinder-search-field:focus-within,
          #unifinder-searchBox menulist:focus-visible {
            border-color: ${base0D} !important;
            outline: 1px solid ${base0D} !important;
          }

          #unifinder-search-results-tree {
            background-color: ${base00} !important;
            color: ${base05} !important;
          }

          #unifinder-search-results-tree treechildren::-moz-tree-row(selected) {
            background-color: ${base0D} !important;
          }

          #unifinder-search-results-tree treechildren::-moz-tree-cell-text(selected) {
            color: ${base00} !important;
          }

          @-moz-document url("chrome://messenger/content/messengercompose/messengercompose.xhtml") {
            #composeContentBox,
            #messageArea,
            #messageEditor {
              background-color: ${base00} !important;
              box-shadow: none !important;
            }

            #MsgHeadersToolbar,
            #FormatToolbox {
              background-color: ${base01} !important;
              color: ${base05} !important;
            }

            #MsgHeadersToolbar {
              padding-block: 6px !important;
            }

            #FormatToolbar {
              padding-block: 4px !important;
              border-bottom: 1px solid ${base02} !important;
            }

            #msgSubject,
            .address-container {
              background-color: ${base00} !important;
              color: ${base05} !important;
              border-color: ${base02} !important;
              border-radius: 6px !important;
            }

            #msgSubject {
              padding-block: 4px !important;
            }

            .address-container {
              padding-block: 3px !important;
            }

            #msgSubject:focus,
            .address-container[focused="true"] {
              border-color: ${base0D} !important;
              outline: 1px solid ${base0D} !important;
            }
          }

          /* indicator of current time of day on cal */
          .multiday-timebar-now-indicator {
              border: 2px solid ${base08} !important;
          }
          .multiday-grid.multiday-grid-rotated .timeIndicator,
          .multiday-grid:not(.multiday-grid-rotated) .timeIndicator {
              border-block-start: 2px solid ${base08} !important;
          }


          /* star button for emails when starred*/
          button.email-action-flagged {
            &.flagged {
              fill: ${base0A} !important;
              stroke: ${base0A} !important;
            }
          }
          /* star button for emails when not starred*/
          button.email-action-flagged {
            fill: transparent !important;
            stroke: ${base0A} !important;
          }

          /* color of unread bubble on card */
          #threadTree[rows="thread-card"] {
            & .card-layout {
              &[data-properties~="unread"] {
                --read-status-fill: ${base0B} !important;
                --read-status-stroke: ${base0B} !important;
              }
            }
          }


          /* color of replied arrow card */
   	 & :is(.subject-line img, .replied) {
	   	 visibility: initial;
		 content: var(--icon-reply-col);
		 fill: ${base0E} !important;
	 }



          /* color of card text */
          #threadTree[rows="thread-card"] {
            & .card-layout {
              & td {
                & .card-container {
                  color: ${base05} !important;
                }
              }
            }
          }


          /* color of buttons in email notifications */
          /* TODO find theme that works (and not just hover) */
          .notification-button {
            &:not([disabled]):hover {
              color: ${base0B} !important;
              background-color: ${base00} !important;
            }
          }

          /* color of warning in email like spam*/
          :host(notification-message[type="warning"]).text-content, div.container, div.content {
            --message-bar-background-color: ${base0A} !important;
            --message-bar-text-color: ${base00} !important;
            border-radius: 0px !important;
          }



        '';

        # Style the editor locally without changing received mail or outgoing HTML.
        userContent = ''
          @-moz-document url("about:blank?compose") {
            html,
            body {
              background-color: ${base00} !important;
              color: ${base05} !important;
            }

            body {
              padding: 12px;
            }
          }
        '';
      };
    };
  };
}
