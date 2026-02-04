{ config, ... }:

with config.lib.stylix.colors.withHashtag;
{
    programs.firefox.profiles.default.userContent = ''

        /* anything here gets applied universally to every page and element */
        :root {
                /* PDF.js tweaks, might specify class further if it causes issues*/
                --body-bg-color: ${base01} !important;
                --field-bg-color: ${base01} !important;
                --toolbar-bg-color: ${base00} !important;
                --toolbar-icon-bg-color: ${base0B} !important;
                --toolbar-border-color: ${base0E} !important;
                --sidebar-toolbar-bg-color: ${base01} !important;
                --toggled-btn-color: ${base09} !important;
                --toggled-btn-bg-color: ${base01} !important;
                --dropdown-btn-bg-color: ${base00} !important;
                --main-color: ${base05} !important;
                --text-color: ${base05} !important;
                --doorhanger-bg-color: ${base00} !important;
                --treeitem-color: ${base09} !important;
                --treeitem-selected-color: ${base0E} !important;
                --treeitem-hover-color: ${base0B} !important;
                --button-hover-color: ${base0A} !important;
                --tab-line-selected-color: ${base0D} !important;
                --tab-line-hover-color: ${base0E} !important;
                /* tweaks to "firefox view" page */
                --fxview-background-color: ${base00} !important;
                --fxview-background-color-secondary: ${base01} !important;
                --fxview-primary-action-background: ${base0D} !important;
                --fxview-border: ${base0F} !important;
                --page-nav-button-text-color: ${base0A} !important;
                --button-text-color: ${base05} !important;

                --theme-selection-background: ${base09} !important;

                /* tab bar on API response page*/
                --theme-tab-toolbar-background: ${base01} !important;

                /* outline around search bars n stuff*/
                --theme-focus-outline-color: ${base0D} !important;

                /* notif bar that appears under URL bar*/
                --info-bar-background-color: ${base02} !important;
                --info-bar-text-color: ${base0A} !important;
        }
        /* current page number in PDF*/
        .toolbarField {
                color: ${base0A} !important;
        }
        /* drop down menu for zooming in PDF reader */
        .dropdownToolbarButton {
                color: ${base05} !important;
                background-color: ${base00} !important;
                border: 1px solid ${base0E} !important;
        }

        .editorParamsSlider {
            background-color: ${base0E};
        }

        /* styling for all input boxes (fixes search on FF view page )*/
        input {
                color: ${base05} !important;
                background-color: ${base01} !important;
                border-color: ${base01} !important;
        }
        /* x symbol in input bars */
        .search-container {
                color: ${base08} !important;
        }


        /* API response pages */
        .panelContent {
            background: ${base01} !important;
        }
        .treeTable .treeRow.selected :where(:not(.objectBox-jsonml)), .treeTable .treeRow.selected .treeLabelCell::after {
            color: ${base00} !important;
        }
        /* this is turning all console messages purple */
        /* .objectBox-textNode, .objectBox-string, .objectBox-symbol {
            color: ${base0E} !important;
        } */
        .treeTable .treeRow.selected :not(input, textarea)::selection {
            color: ${base00} !important;
            background-color: ${base0D} !important;
        }
        .toolbar .btn {
            color: ${base00} !important;
            background: ${base0D} !important;
        }
        .toolbar .btn:hover {
            color: ${base00} !important;
            background: ${base0B} !important;
        }
        .toolbar {
            background: ${base01} !important;
        }

        /* text color of visited links */
        /* works for some, darkdreader seems to override others */
        .a:visited:not(.no-visited) {
            color: ${base0E} !important;
        }

        /* styling to apply to all about: pages */
        /* https://github.com/ATechnocratis/widefox/blob/main/chrome/userContent-files/aboutpages/about_pages_Darker.css */
        @-moz-document url-prefix("about:"),
        url-prefix("chrome://userchromejs/content/aboutconfig/aboutconfig.xhtml"),url-prefix(view-source)  {
            :root {
                --primary-background: ${base00} !important;
                --bg-color: ${base00} !important;
                --secondary-background: ${base01} !important;
                --primary-font-color: ${base05} !important;
                --background-color-box: ${base01} !important;
                --highlighted-font-color: ${base00} !important;
                --primary-border: 1px solid ${base0E} !important;
                --bright-border: 1px solid ${base0A} !important;
                --border-color: ${base0D} !important;
                --bright-border-color: ${base0A} !important;
                --primary-icon-color: ${base05} !important;
                --faded-bright-border-color: rgba(${base0A-rgb-r}, ${base0A-rgb-g}, ${base0A-rgb-b}, .65) !important;
                --in-content-border-focus: ${base0E} !important;
                --in-content-border-color: ${base09} !important;
                /* --primary-accent-color: ${base0D} !important; */
                --color-accent-primary: ${base0E} !important;
                --color-accent-primary-hover: ${base0D} !important;
                --in-content-page-background: ${base00};
                --in-content-page-color: ${base05} !important;
                --in-content-box-background-alt: ${base01} !important;
                --in-content-box-info-background: ${base00} !important;
                --in-content-button-background: ${base01} !important;
                --in-content-button-background-alt: ${base00} !important;
                --in-content-box-border-color: ${base01} !important;
                --in-content-box-background: ${base00} !important;
                --in-content-box-background-op: rgba(${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b}, 0.5) !important;
                --in-content-primary-button-background: ${base0D} !important;
                --in-content-primary-button-background-hover: ${base0B} !important;
                --in-content-primary-button-background-active: ${base0C} !important;
                --in-content-text-color: ${base05} !important;
                --in-content-focus-outline-color: ${base09} !important;
                --search-box: ${base00} !important;
                --checkbox-checked-color: ${base0B} !important;
                --in-content-item-selected: ${base0B} !important;
                --in-content-primary-button-text-color: var(--highlighted-font-color) !important;
                --in-content-category-text-hover: HighlightText  !important;
                --in-content-category-background-hover: Highlight  !important;
                --in-content-category-text-selected: ${base00}  !important;
                --in-content-category-text-selected: ${base05}  !important;
                --in-content-category-background-selected: ${base01} !important;

                /* color of toggle button nubs and other toggle colors*/
                --background-color-canvas: ${base00} !important;
                
                --card-outline-color: ${base09} !important;

                --theme-icon-color: ${base0B} !important;
                --theme-icon-dimmed-color: ${base04} !important;
                --theme-icon-checked-color: ${base0D} !important;
                --theme-icon-warning-color: ${base09} !important;

                --table-row-background-color-alternate: ${base01} !important;

            }
            @media (min-width: 830px) {
                :root {
                    --in-content-page-background: ${base00}!important;
                }
            } 
        }

        /* specific styling for about:preferences */
        @-moz-document url-prefix("about:preferences") {
            h1 {
                font-size: 1.5em!important;
                font-weight: 900 !important;
            }
            .main-content {
                background-color: ${base00} !important;
                color: ${base05}!important;
            }
            .sticky-container {
                background-color: ${base00} !important;
            }
            #categories>.category[selected], #categories>.category.selected {
                color: ${base08} !important;
            }
            html, h1, #categories {
                color: ${base05} !important;
            }
            .navigation, #handersView, #engineShown, #engineName, #engineKeyword, .dialogTitleBar {
                background-color: ${base01} !important;
                color: ${base05} !important;
            }
            #searchInput {
                background-color: ${base01} !important;
                color: ${base09} !important;
            }
            #filter {
                background-color: ${base01} !important;
                color: ${base09} !important;
            }
            #downloadFolder {
                background-color: ${base01} !important;
                color: ${base09} !important;
            }
            #typeColumn {
                background-color: ${base01} !important;
                color: ${base09} !important;
            }
            #actionColumn {
                background-color: ${base01} !important;
                color: ${base09} !important;
            }
            #handlersView {
                background-color: ${base01} !important;
                color: ${base05} !important;
            }
            #applicationsGroup listheader {
                background-color: ${base01} !important;
            }
            #contentBlockingOptionStandard, #contentBlockingOptionStrict, #contentBlockingOptionCustom {
                background-color: ${base01} !important;
                color: ${base05} !important;
                border: 0px  !important;
            }
            description {
                color: ${base05} !important;
            }
            #engineChildren {
                background-color: ${base01} !important;
                color: ${base05} !important;
            }
            .content-blocking-warning {
                background: ${base01} !important;
            }
            .checkbox-check, input[type="checkbox"] {
                border: 1px dashed var(--in-content-accent-color)  !important;
                background-color: transparent  !important;
                -moz-appearance: none  !important;
                opacity: 0.7 !important;
            }
            .checkbox-check[checked] {
                opacity: 1 !important;
            }
            input[type="checkbox"] {
                border: 1px dashed ${base0D}  !important;
                background-color: transparent  !important;
                -moz-appearance: none  !important;
            }
            .radio-check {
                background-color: transparent  !important;
            }
        }

        /* specific styling for addons manager */
        @-moz-document url-prefix("about:addons") {
            #sidebar {
                background-color: ${base01};
            }
            #full {
                color: ${base05} !important;
            }
            .card {
                background-color: ${base01} !important;
                color: ${base05} !important;
            }
            #searchInput {
                background-color: ${base01} !important;
                color: ${base09} !important;
            }
        }

        /* specific styling for support page */
        @-moz-document url-prefix("about:support") {
            :root {
                --in-content-table-background: ${base01} !important;
            }
            table {
                background-color: ${base01} !important;
            }
        }

        /* specific styling for debugging page */
        @-moz-document url-prefix(about:debugging) {
            :root {
                --bg-color: ${base00} !important;
                --box-background: ${base01} !important;
                --box-border-color: ${base0D} !important;
                --text-color: ${base05} !important;
                --caption-20-color: ${base05} !important;
                --sidebar-selected-color: ${base05} !important;
                --card-separator-color: rgba(${base0B-rgb-r}, ${base0B-rgb-g}, ${base0B-rgb-b}, .65) !important;
            }
            .sidebar-item__link, .sidebar-item__link:hover {
                color: ${base05} !important;
                filter: sepia(0.1) !important;
            }
            .connect-section__header__icon, .connect-section__header__icon, .sidebar__footer__icon, .icon-label__icon {
                filter: invert(1) !important;
            }
            .default-button {
                color: ${base0A} !important;
                background-color: ${base01} !important;
            }
            .sidebar__label, .fieldpair__description {
                color: ${base05} !important;
            }
            .sidebar-item:not(.sidebar-item--selectable) {
                color: ${base05} !important;
            }
            .sidebar {
                background-color: ${base01} !important;
            }
            .card {
                background: ${base01} !important;
            }
            .fieldpair {
                border-color: ${base0C} !important;
            }
        }

        @-moz-document url-prefix(about:performance) {
            html, #dispatch-table {
                background:none!Important;
            }
            #dispatch-thead>tr>td {
                background-color: ${base00};
                backdrop-filter: blur(10px);
            }
            td {
                color: ${base01} !important;
            }
            #column-name {
                padding-right: 60px!important;
            }
            #column-type {
                padding-right: 0px!important;
            }
            td {
                min-width: 10px!Important;
                width: 20px!Important;
            }
        }


        /* change highlighted text color in web pages (not URL bar) */
        @layer {
            ::selection {
                background-color: ${base0D} !important;
                color: ${base00} !important;
            }
            ::-moz-selection {
                background-color: ${base0D} !important;
                color: ${base00} !important;
            }
        }

        /* View source syntax highlighting */
        @media (-moz-bool-pref: "view_source.syntax_highlight") {
        .start-tag,
        .end-tag {
            color: ${base0E} !important;
            font-weight: bold;
        }
        .comment {
            color: ${base04} !important;
            /* font-style: italic; */
        }
        .cdata {
            color: ${base08} !important;
        }
        .doctype,
        .markupdeclaration {
            color: ${base0D} !important;
            font-style: italic;
        }
        .pi {
            color: ${base0E} !important;
            font-style: italic;
        }
        .entity {
            color: ${base08} !important;
        }
        .text {
            font-weight: normal;
            color: ${base05} !important;
        }
        .attribute-name {
            font-weight: bold;
        }
        .attribute-value {
            color: ${base09} !important;
            font-weight: normal;
        }
        .error {
            color: ${base08} !important;
            font-weight: bold;
            text-decoration: underline wavy ${base08} 0.5px !important;
        }
        }

    /* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/content/auto_devtools_theme.css */
    /* Make devtools use dark theme if your OS is in dark mode. Set devtools to Light-theme for this style to work */
    @-moz-document url("about:devtools-toolbox"), url-prefix("chrome://devtools/content/"){
        @media(prefers-color-scheme: dark){
        :root {
            --badge-active-background-color: ${base0D} !important;
            --badge-active-border-color: ${base08} !important;
            --badge-background-color: ${base00} !important;
            --badge-border-color: ${base0A} !important;
            --badge-color: ${base05} !important;
            --badge-hover-background-color: ${base01} !important;
            --badge-interactive-background-color: ${base01} !important;
            --badge-interactive-color: ${base0A} !important;
            --badge-scrollable-color: ${base0E} !important;
            --badge-scrollable-background-color: transparent !important;
            
            --tab-line-hover-color: ${base08} !important;
            --toggle-thumb-color: var(--grey-40) !important;
            --toggle-track-color: var(--grey-60) !important;
            --searchbox-no-match-background-color: ${base00} !important;
            --searchbox-no-match-stroke-color: ${base08} !important;
            
            --bezier-diagonal-color: ${base05} !important;
            
            --bezier-grid-color: rgba(0, 0, 0, 0.2) !important;
            --theme-tooltip-color: var(--theme-text-color-strong) !important;
            --theme-tooltip-background: ${base00} !important;
            --theme-tooltip-shadow: rgba(25, 25, 25, 0.76) !important;
            --theme-tooltip-icon-dimmed-color: rgb(255, 255, 255) !important;
            --theme-arrowpanel-background: var(--theme-popup-background) !important;
            --theme-arrowpanel-color: var(--theme-popup-color) !important;
            --theme-arrowpanel-border-color: var(--theme-popup-border-color) !important;
            --theme-arrowpanel-separator: ${base0F} !important;
            --theme-arrowpanel-dimmed: var(--theme-popup-dimmed) !important;
            --theme-arrowpanel-dimmed-further: rgba(249,249,250,.15) !important;
            --theme-arrowpanel-disabled-color: rgba(249,249,250,.5) !important;
            
            --theme-body-background: ${base00} !important;
            --theme-body-emphasized-background: ${base01} !important;
            --theme-sidebar-background: ${base00} !important;

            /* Toolbar */
            --theme-tab-toolbar-background: ${base01} !important;
            --theme-toolbar-background: ${base00} !important;
            --theme-toolbar-color: ${base05} !important;
            --theme-toolbar-selected-color: ${base05} !important;
            --theme-toolbar-highlighted-color: ${base0B} !important;
            --theme-toolbar-background-hover: ${base01} !important;
            --theme-toolbar-background-alt: ${base01} !important;
            --theme-toolbar-hover: ${base01} !important;
            --theme-toolbar-hover-active: ${base02} !important;
            --theme-toolbar-separator: ${base0E} !important;


            /* Toolbar buttons */
            --toolbarbutton-background: ${base00} !important;
            --toolbarbutton-hover-background: ${base01} !important;
            --toolbarbutton-focus-background: ${base01} !important;
            --toolbarbutton-focus-color: ${base0B} !important;
            --toolbarbutton-checked-background: ${base0A} !important;
            --toolbarbutton-checked-focus-background: ${base0B} !important;
            --toolbarbutton-checked-color: ${base05} !important;

            /* Buttons */
            --theme-button-background: ${base00} !important;
            --theme-button-active-background: ${base01} !important;

            /* Accordion headers */
            --theme-accordion-header-background: ${base00} !important;
            --theme-accordion-header-hover: ${base01} !important;

            /* Selection */
            --theme-selection-background: ${base09} !important;
            --theme-selection-background-hover: ${base01} !important;
            --theme-selection-focus-background: ${base01} !important;
            --theme-selection-color: ${base00} !important;

            /* Border color that splits the toolbars/panels/headers. */
            --theme-splitter-color: ${base04} !important;
            --theme-emphasized-splitter-color: ${base0A} !important;
            --theme-emphasized-splitter-color-hover: ${base09} !important;

            /* Icon colors */
            --theme-icon-color: ${base0B} !important;
            --theme-icon-dimmed-color: ${base04} !important;
            --theme-icon-checked-color: ${base0D} !important;
            --theme-icon-error-color: ${base08} !important;
            --theme-icon-warning-color: ${base0A} !important;

            /* Text color */
            --theme-comment: ${base04} !important;
            --theme-body-color: ${base05} !important;
            --theme-text-color-alt: ${base04} !important;
            --theme-text-color-inactive: ${base04} !important;
            --theme-text-color-strong: ${base0E} !important;
            --theme-stack-trace-text: ${base08} !important;
            --theme-internal-link-color: ${base0D} !important;

            --theme-highlight-green: ${base0B} !important;
            --theme-highlight-blue: ${base0D} !important;
            --theme-highlight-purple: ${base0E} !important;
            --theme-highlight-red: ${base08} !important;
            --theme-highlight-yellow: ${base0A} !important;

            /* These theme-highlight color variables have not been photonized. */
            --theme-highlight-bluegrey: ${base0D} !important;
            --theme-highlight-lightorange: ${base09} !important;
            --theme-highlight-orange: ${base09} !important;
            --theme-highlight-pink: ${base0E} !important;
            --theme-highlight-gray: ${base05} !important;

            /* For accessibility purposes we want to enhance the focus styling. This
            * should improve keyboard navigation usability. */
            --theme-focus-outline-color: ${base04} !important;

            /* Colors used in Graphs, like performance tools. Mostly similar to some "highlight-*" colors. */
            --theme-graphs-green: ${base0B} !important;
            --theme-graphs-blue: ${base0D} !important;
            --theme-graphs-bluegrey: ${base0D} !important;
            --theme-graphs-purple: ${base0E} !important;
            --theme-graphs-yellow: ${base0A} !important;
            --theme-graphs-orange: ${base09} !important;
            --theme-graphs-red: ${base08} !important;
            --theme-graphs-grey: ${base04} !important;
            --theme-graphs-full-red: ${base08} !important;
            --theme-graphs-full-blue: ${base0D} !important;

            /* Common popup styles(used by HTMLTooltip and autocomplete) */
            --theme-popup-background: ${base01} !important;
            --theme-popup-color: ${base0A} !important;
            --theme-popup-border-color: ${base0A} !important;
            --theme-popup-dimmed: rgba(249, 249, 250, 0.1) !important;

            /* Styling for devtool buttons */
            --theme-toolbarbutton-background: ${base01} !important;
            --theme-toolbarbutton-color: ${base0A} !important;
            --theme-toolbarbutton-hover-background: ${base00} !important;
            --theme-toolbarbutton-checked-background: ${base0E} !important;
            --theme-toolbarbutton-checked-color: ${base00} !important;
            --theme-toolbarbutton-checked-hover-background: ${base08} !important;
            --theme-toolbarbutton-checked-hover-color: ${base00} !important;
            --theme-toolbarbutton-active-background: ${base00} !important;
            --theme-toolbarbutton-active-color: ${base0B} !important;

            --theme-toolbar-selected-color: ${base09} !important;
            --theme-toolbar-hover-color: ${base0E} !important;

            /* Used for select elements */
            --theme-select-background: ${base01} !important;
            --theme-select-color: ${base05} !important;
            --theme-select-hover-border-color: ${base03} !important;

            /* Warning colors */
            --theme-warning-background: ${base00} !important;
            --theme-warning-border: ${base08} !important;
            --theme-warning-color: ${base08} !important;

            /* Flashing colors used to highlight updates */
            --theme-contrast-background: #4f4b1f !important; /* = Yellow 50-a20 on body background */
            --theme-contrast-background-alpha: rgba(255, 233, 0, 0.15) !important; /* Yellow 50-a15 */
            --theme-contrast-color: ${base05} !important;
            --theme-contrast-border: ${base0A} !important;
            
            --markup-hidden-attr-name-color: ${base04} !important;
            --markup-hidden-attr-value-color: ${base05} !important;
            --markup-hidden-punctuation-color: ${base04} !important;
            --markup-hidden-tag-color: ${base04} !important;
            --markup-outline: var(--theme-selection-background) !important;
            --markup-drag-line: ${base04} !important;
            --markup-drop-line: ${base0D} !important;
            --markup-overflow-causing-background-color: rgba(148, 0, 255, 0.38) !important;
            
            --console-input-background: var(--theme-tab-toolbar-background) !important;
            --console-message-background: var(--theme-body-background) !important;
            --console-message-border: var(--theme-splitter-color) !important;
            --console-message-color: ${base05} !important;
            --console-error-background: ${base00} !important;
            --console-error-border: var(--theme-splitter-color) !important;
            --console-error-color: ${base08} !important;
            --console-warning-border: var(--theme-splitter-color) !important;
            --console-warning-color: ${base09} !important;
            --console-navigation-color: var(--theme-highlight-blue) !important;
            --console-navigation-border: ${base0D} !important;
            --console-indent-border-color: var(--theme-highlight-blue) !important;
            --console-repeat-bubble-background: ${base0D} !important;
            --error-color: ${base08} !important;
            --console-output-color: ${base05} !important;
            
            --scrollbar-color: ${base04} var(--theme-splitter-color) !important;

            --tab-line-selected-color: ${base0D} !important;

            /* graphs on networking tab */
            --timing-wait-color: ${base0D} !important;
            --timing-send-color: ${base0C} !important;
            --timing-receive-color: ${base0B} !important;
            --timing-connect-color: ${base09} !important;
            --timing-ssl-color: ${base0A} !important;
            --timing-dns-color: ${base0E} !important;
            --timing-server-color-1: ${base0E} !important;
            --timing-server-color-2: ${base0F} !important;
            --timing-server-color-3: ${base0C} !important;
            --timing-server-color-total: ${base09} !important;

            /* rule header for styles */
            --rule-header-background-color: ${base01} !important;
        }
        }


        /* Toolbox */
        .devtools-tabbar {
        color: ${base05} !important;
        background-color: ${base01} !important;
        }
        .devtools-tab {
        background-color: ${base00} !important;
        color: ${base05} !important;
        }
        .devtools-tab:hover {
        background-color: ${base01} !important;
        color: ${base0E} !important;
        }
        .devtools-tab:active {
        background-color: ${base01} !important;
        color: ${base0D} !important;
        }
        .devtools-tab.selected {
        color: ${base09} !important;
        }

        /* toolbox error button */
        .toolbox-error::before {
        fill: ${base08} !important;
        }

        /* Notification box (above toolbox) */
        .notificationbox .notification {
        color: ${base05} !important;
        background-color: ${base01} !important;
        }

        /* badge for XHR requests */
        .webconsole-app .message.network .xhr {
            background-color: ${base09} !important;
            color: ${base00} !important;
        }

        /* request and response error header */
        .theme-dark .network-monitor .request-error-header, .theme-dark .network-monitor .response-error-header {
        background-color: ${base08} !important;
        color: ${base00} !important;
        }

        /* "Start recording" button on performance page */
        .perf-photon-button-primary {
        background-color: ${base0D} !important;
        color: ${base00} !important;
        }
        .perf-photon-button-primary:hover:not([disabled]) {
        background-color: ${base0B} !important;
        }
        .perf-photon-button-primary:hover:active:not([disabled]) {
        background-color: ${base08} !important;
        }
    }


    /* Fixes for Reddit Enhancement Suite */
    &.res-commentBoxes .comment,
    &.res-commentBoxes .comment .comment .comment,
    &.res-commentBoxes .comment .comment .comment .comment .comment,
    &.res-commentBoxes .comment .comment .comment .comment .comment .comment .comment,
    &.res-commentBoxes .comment .comment .comment .comment .comment .comment .comment .comment .comment {
        background-color: ${base00} !important;
    }

    &.res-commentBoxes .comment .comment,
    &.res-commentBoxes .comment .comment .comment .comment,
    &.res-commentBoxes .comment .comment .comment .comment .comment .comment,
    &.res-commentBoxes .comment .comment .comment .comment .comment .comment .comment .comment,
    &.res-commentBoxes .comment .comment .comment .comment .comment .comment .comment .comment .comment .comment {
        background-color: ${base01} !important;
    }
    &.res-commentBoxes .comment .comment {
        background-color: ${base00} !important;
    }
    .res-commentBoxes .comment {
        border: 1px solid ${base02} !important;
    }
    .res-voteEnhancements-highlightScores span.score {
        color: ${base0E} !important;
    }
    '';
}