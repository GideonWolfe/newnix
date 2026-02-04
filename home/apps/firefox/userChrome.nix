{ config, ... }:

with config.lib.stylix.colors.withHashtag;
{
    programs.firefox.profiles.default.userChrome = ''
        /* root variables to propagate through MANY UI elements */
        :root {
            --in-content-page-background: ${base00} !important;
            --in-content-page-color: ${base05} !important;
            --in-content-text-color: var(--in-content-page-color);
            --in-content-box-background-odd: ${base01};
            --in-content-box-info-background: ${base00};
            --in-content-box-border-color: ${base0F};
            --in-content-border-color: ${base0F};
            --in-content-border-invalid: ${base08};
            --in-content-item-hover: color-mix(in srgb, var(--in-content-primary-button-background) 20%, transparent);
            --in-content-item-hover-text: var(--in-content-page-color);
            --in-content-item-selected: var(--in-content-primary-button-background);
            --in-content-item-selected-text: var(--in-content-primary-button-text-color);
            --in-content-primary-button-text-color: ${base00};
            --in-content-primary-button-text-color-hover: var(--in-content-primary-button-text-color);
            --in-content-primary-button-text-color-active: var(--in-content-primary-button-text-color);
            --in-content-primary-button-background: ${base0D} !important;
            --in-content-primary-button-background-hover: ${base16};
            --in-content-primary-button-background-active: ${base0C};
            --in-content-primary-button-border-color: transparent;
            --in-content-primary-button-border-hover: transparent;
            --in-content-primary-button-border-active: transparent;
            --in-content-danger-button-background: ${base08};
            --in-content-danger-button-background-hover: ${base12};
            --in-content-danger-button-background-active: ${base09};
            --in-content-button-text-color: var(--in-content-text-color);
            --in-content-button-text-color-hover: var(--in-content-text-color);
            --in-content-button-text-color-active: var(--in-content-button-text-color-hover);
            --in-content-button-background: ${base01};
            --in-content-button-background-hover: ${base00};
            --in-content-button-background-active: color-mix(in srgb, currentColor 21%, transparent);
            --in-content-button-border-color: transparent;
            --in-content-button-border-color-hover: transparent;
            --in-content-button-border-color-active: var(--in-content-button-border-color-hover);
            --in-content-table-background: ${base00};
            --in-content-table-border-color: var(--in-content-box-border-color);
            --in-content-table-header-background: var(--in-content-primary-button-background);
            --in-content-table-header-color: var(--in-content-primary-button-text-color);
            --card-outline-color: ${base0B} !important;
            --dialog-warning-text-color: ${base08};
            --focus-outline-color: ${base09};
            --in-content-focus-outline-color: var(--focus-outline-color);
            --background-color-box: ${base00} !important;
        }

        /* get rid of blinding white loading screen for tabs */
        .browserContainer { background-color: ${base00} !important; }

        /*------------- STATUS PANEL ------------------*/


        /* color of url loading bar at bottom left */
        #statuspanel-label {
            background-color: ${base00} !important;
            color: ${base0E} !important;
            border-color: ${base0D} !important;
        }

        /* Change background color for both private and non-private windows */
        @-moz-document url("chrome://browser/content/browser.xhtml") {
            /* Non-private window background color */
            #appcontent, #appcontent tabpanels, browser[type="content-primary"], browser[type="content"] > html, browser[type="content"] > html > body {
                background-color: ${base00} !important;
            }
        }


        /* Hover tooltip style, only themes some ie. refresh button*/
        tooltip {
            color: ${base05} !important;
            background-color: ${base00} !important;
            -moz-appearance: none !important;
            border: 1px solid ${base0D};
            border-radius: 2px;
        }	

        /*--------------- TOOLBAR ----------------*/

        /* Changes color of toolbar */
        #navigator-toolbox{ --toolbar-bgcolor: ${base00} }

        /* List all tabs dropdown button */
        #alltabs-button { color: ${base0D} !important; }

        /* Browser home button */
        #home-button { color: ${base0B} !important; }

        /* Shield icon */
        #tracking-protection-icon-box {
            color: ${base0C} !important;
        }
        #urlbar-input-container[pageproxystate="valid"] #tracking-protection-icon-box:not([hasException])[active] > #tracking-protection-icon{
            color: ${base08} !important;
        }

        /* Back button coloring color */
        #back-button:not([disabled="true"]):not([open="true"]):not(:active) .toolbarbutton-icon {
            background-color: ${base00} !important;
            color: ${base09} !important;
        }

        /* Back button coloring */
        #forward-button{
            color: ${base0B} !important;
        }

        /* Refresh button coloring */
        #reload-button{
            color: ${base0D} !important;
        }

        /* Cancel Loading button coloring */
        #stop-button{
            color: ${base08} !important;
        }

        /* webcam enabled recording coloring */
        #webrtc-sharing-icon[sharing]:not([paused]) {
            fill: ${base08} !important;
        }

        /* settings button for when permissions are used */
        #permissions-granted-icon {
            color: ${base09} !important;
        }

        /* Downloads button coloring */
        #downloads-button{
            color: ${base0E} !important;
            accent-color: ${base0E} !important;
        }	
        /* Downloads progress inner circle coloring */
        #downloads-indicator-progress-inner{
            --toolbarbutton-icon-fill-attention: ${base0B} !important;
        }	
        /* Downloads dropdown progress bar coloring */
        .downloadProgress::-moz-progress-bar {
            --download-progress-fill-color: ${base09};
        }

        /* example of setting image as icon https://www.reddit.com/r/FirefoxCSS/comments/cy8w4d/new_tab_button_customization/ */
        /* New Tab Buttons */
        /* the weirdness of these buttons https://www.reddit.com/r/FirefoxCSS/comments/12mjsk1/change_color_of_add_new_tab_button/ */
        :is(#new-tab-button, #tabs-newtab-button) > .toolbarbutton-icon {
            color: ${base0C} !important;
        }
        :is(#new-tab-button, #tabs-newtab-button):hover > .toolbarbutton-icon {
            color: ${base0C} !important;
        }

        /* Hamburger Menu icon in toolbar */
        #PanelUI-menu-button {
            color: ${base0E} !important;
        }
        /* Extensions icon in toolbar */
        #unified-extensions-button{
            color: ${base0F} !important;
        }
        /* Account icon in toolbar */
        #fxa-toolbar-menu-button{
            color: ${base08} !important;
        }

        /* Disable favorite star button */
        #star-button-box { display:none !important; }

        /* close button */
        #browser-window-close-button{
            color: ${base08} !important;
        }

        /* Reader view icon */
        #reader-mode-button-icon { color: ${base09} !important }
        /* #reader-mode-button[readeractive] > .urlbar-icon { */
        /*	color: ${base0E} !important */
        /* } */

        #reader-mode-button[readeractive] > .urlbar-icon {
            fill: ${base08} !important;
        }


        #urlbar-zoom-button {
            background-color: ${base00}!important;
            color: ${base0A} !important;
        }
        #urlbar-zoom-button:hover {
            background-color: ${base0A}!important;
            color: ${base00} !important;
        }

        /*-----------------------------------------*/


        /*----------------- TABS ------------------*/

        /* Disable Favicons */
        .tab-icon-image {
            display: none !important;
        }

        /* main tab background */
        .tabbrowser-tab {
            background: ${base00} !important;
        }

        /* background of hovered tabs */
        .tabbrowser-tab:hover {
            color: ${base01} !important;
        }
        /* text of hovered tabs */
        .tabbrowser-tab:hover .tab-label {
            color: ${base07} !important;

        }

        /* Colors text and background of tab label */
        .tabbrowser-tab .tab-label {
            color: ${base05} !important;
            background-color: ${base00} !important;
        }

        /* Text of secondary tab text (ie. "Playing") */
        .tab-secondary-label {
            color: ${base0D};
        }
        /* Secondary text when audio is muted */
        .tab-secondary-label[muted] {
            color: ${base08};
        }

        /* Colors text and background of tab label (selected)*/
        .tabbrowser-tab[selected="true"] .tab-label {
            color: ${base0B} !important;
            background-color: ${base00} !important;
            font-weight: bold !important;
        }

        /* Background color of tab itself (selected) */
        .tabbrowser-tab[selected] .tab-content {
            background-color: ${base00} !important; 
        }

        .tabbrowser-tab .tab-close-button {
            color: ${base08};
        }

        /* Style for Magnifying glass icon in search bar */
        #urlbar:not(.searchButton) > #urlbar-input-container > #identity-box[pageproxystate="invalid"] {
            color: ${base0E} !important;
        }

        /* Style for close tab buttons */
        .tabbrowser-tab:not([pinned]) .tab-close-button {
            color: ${base0D} !important;
        }
        .tabbrowser-tab:not([pinned]):hover .tab-close-button {
            color: ${base08} !important;
            font-weight: bold !important;
        }

        .tabbrowser-tab[pinned] {
            width: 100px;
            border: 1px solid ${base0E} !important;
            font-style: italic !important;
        }
        /* .tab-background[pinned] { */
        /*     border: 1px solid ${base0E} !important; */
        /* } */


        /* Speaker icon on tab playing media  */
        /* TODO not sure what activemedia-blocked does, may want to style differently  */
        .tab-icon-overlay:not([crashed]):is([soundplaying],[activemedia-blocked]) {
            background-color: ${base0B} !important;
            fill: ${base00} !important;
        }
        /* Speaker icon on tab playing media hovering */
        .tab-icon-overlay:not([crashed]):is([soundplaying],[activemedia-blocked]):hover {
            background-color: ${base09} !important;
            fill: ${base00} !important;
        }
        /* Speaker icon on tab muted media  */
        .tab-icon-overlay:not([crashed]):is([muted],[activemedia-blocked]) {
            background-color: ${base08} !important;
            fill: ${base00} !important;
        }
        /* Speaker icon on tab muted media hovering */
        .tab-icon-overlay:not([crashed]):is([muted],[activemedia-blocked]):hover {
            background-color: ${base0D} !important;
            fill: ${base00} !important;
        }

        /*-----------------------------------------*/


        .findbar {
            background-color: ${base00};
            -moz-appearance: none !important;
        }
        .findbar-container {
            background-color: ${base00};
        }

        /* bg/border of find bar */
        .browserContainer > findbar {
            background-color: ${base00} !important;
            border-top-color: ${base0E} !important;

        }

        /* Search box when no results found */
        .findbar-textbox[status="notfound"] {
            background-color: ${base00} !important;
            color: ${base08} !important;
        }

        /* Arrow buttons when no search entered */
        .findbar-find-previous[disabled="true"] > .toolbarbutton-icon,
        .findbar-find-next[disabled="true"] > .toolbarbutton-icon {
            fill: ${base08} !important;
        }
        /* Arrows when results found */
        .findbar-find-previous {
            fill: ${base0A} !important;
        }
        .findbar-find-next {
            fill: ${base0B} !important;
        }

        /* Close Icon */
        findbar > .close-icon{
            background-color: ${base00} !important;
            pointer-events: auto;
        }
        .close-icon.findbar-closebutton {
            fill: ${base08} !important;
        }

        /* Color of "Phrase not Found" */
        .findbar-find-status{
            color: ${base08};
        }

        /* Replace checkboxes with buttons */
        findbar .checkbox-check {
            display: none !important;
        }
        findbar checkbox {
            background: ${base00};
            transition: 0.1s ease-in-out;
            border: 1px solid ${base0D};
            border-radius: 2;
            padding: 2px 4px;
            margin: -2px 4px !important;
        }
        findbar checkbox[checked="true"] {
            background: ${base00};
            color: ${base0B};
            transition: 0.1s ease-in-out;
        }
        .found-matches {
            color: ${base0B};
        }


        /*-----------------------------------------*/

        /*------------- SITE SECURITY ICON --------*/

        /* Green */
        #identity-box[pageproxystate="valid"].verifiedDomain #identity-icon {
            fill: ${base0B} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }
        #identity-box[pageproxystate="valid"].mixedActiveBlocked #identity-icon {
            fill: ${base0B} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }
        #identity-box[pageproxystate="valid"].verifiedIdentity #identity-icon {
            fill: ${base0B} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }
        #identity-popup[connection^="secure"] .identity-popup-security-connection {
            fill: ${base0B} !important;
        }

        /* Red */
        #identity-box[pageproxystate="valid"].notSecure #identity-icon {
            fill: ${base08} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }
        #identity-box[pageproxystate="valid"].mixedActiveContent #identity-icon {
            fill: ${base08} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }
        #identity-box[pageproxystate="valid"].insecureLoginForms #identity-icon {
            fill: ${base08} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }
        .identity-popup-security-connection {
            fill: ${base08};
        }

        /* Orange */
        #identity-box[pageproxystate="valid"].mixedDisplayContent #identity-icon {
            fill: ${base09} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }
        #identity-popup[mixedcontent~="passive-loaded"][isbroken] .identity-popup-security-connection {
            fill: ${base09} !important;
        }

        /* Yellow */
        #identity-box[pageproxystate="valid"].mixedDisplayContentLoadedActiveBlocked #identity-icon {
            fill: ${base0A} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }
        #identity-box[pageproxystate="valid"].certUserOverridden #identity-icon {
            fill: ${base0A} !important;
            fill-opacity: 1 !important;
            transition: 100ms linear !important;
        }

        /*-----------------------------------------*/

        /*------------- CONTEXT MENUS  --------*/

        #context-back {
            color: ${base09} !important;
        }
        #context-forward {
            color: ${base0B} !important;
        }
        #context-reload {
            color: ${base0D} !important;
        }
        #context-stop {
            color: ${base08} !important;
        }
        #context-bookmarkpage {
            color: ${base0A} !important;
        }

        /*-----------------------------------------*/

        /*TODO does this do anything?*/
        :root[hasbrowserhandlers="true"] body.dark.serif {
            background-color: ${base00} !important;
            color: ${base05} !important;
        }
            



        /*-------------- TODO ----------------------*/
        /* Change context menu separators *\
        /* Close window button *\
        /* Reader view button when reader is active *\

    '';
}