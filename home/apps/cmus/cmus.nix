{config, ...}:
{
    programs.cmus = {
        enable = true;
        extraConfig = ''
            # Clear the library before adding new paths
            clear
            # Add library
            #add /nas/tank/media/music/

            # Enable the mouse
            set mouse=true

            # Color of command line text
            set color_cmdline_fg=red

            # Color of status line
            set color_statusline_bg=black
            set color_statusline_fg=magenta

            # Playing Track in Status Line
            set color_titleline_fg=green
            set color_titleline_bg=black


            # Playing Track/Artist/Album in Track Pane
            set color_win_cur=green

            # When Cursor is over playing track in track pane
            set color_win_cur_sel_bg=black
            set color_win_cur_sel_fg=blue
            set color_win_cur_sel_attr=bold

            # When Cursor is over playing track in track pane but inactive
            set color_win_inactive_cur_sel_fg=white
            set color_win_inactive_cur_sel_bg=black
            set color_win_cur_sel_attr=bold


            # Album Title in track pane
            set color_trackwin_album_fg=yellow

            # Album Separator line in Track Pane
            set color_separator=blue

            # Active Selection
            set color_win_sel_bg=black
            set color_win_sel_fg=magenta
            set color_win_sel_attr=bold

            # Inactive Selection
            set color_win_inactive_sel_bg=black
            set color_win_inactive_sel_fg=yellow


            # Color of window title (Settings, Library, etc.)
            set color_win_title_fg=red
            set color_win_title_bg=black

            set format_current=  %a  %l%!  %n. %t%=  %y


            # Keybinds

            # Shift J/K to jump up and down
            bind -f common K win-up 5
            bind -f common J win-down 5
        '';
    };
}