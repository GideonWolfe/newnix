{ pkgs, lib, config, osConfig, ... }:

{
	xdg.configFile.halloy-config = {
		enable = true;
		target = "halloy/config.toml";
		text = ''
			theme = "Stylix"
			scale_factor = 1.3

			[servers.liberachat]
			nickname = "demoncore"
			username = "demoncore"
			realname = "demoncore"
			nick_password_file = "${osConfig.sops.secrets."irc/libera/password".path}"
			server = "irc.libera.chat"
			port = 6697
			channels = [
					"#halloy",
					"#python",
					"#linux",
					"#python",
					"#security",
					"#networking",
					"#bash",
					"#git",
					"##programming",
					"#go-nuts",
					"#hardware",
					"#vim",
					"#wireguard",
					"#weechat",
					"#docker",
					"#nixos",
					"#neovim",
					"##math",
					"#raspberrypi",
					"#systemd",
					"#hamradio",
					"##rtlsdr",
					"#javascript",
					"#nextcloud",
					"#datahoarder",
					"#firefox",
					"#gamingonlinux",
					"#arduino",
					"##space",
					"#latex",
					"#neomutt",
					"##science",
					"#blender",
					"##ibmthinkpad",
					"#sonar",
					"#devops",
					"#jellyfin",
					"##astronomy",
					"##re",
					"#godotengine",
					"#mechboards"
			]

			[file_transfer]
			save_directory = "${config.xdg.userDirs.download}"

			[font]
			family = "${config.stylix.fonts.monospace.name}"
			size = ${builtins.toString config.stylix.fonts.sizes.desktop}

			[keyboard]
			move_up = "alt+k"
			move_down = "alt+j"
			move_left = "alt+h"
			move_right = "alt+l"

			[pane]
			split_axis = "horizontal"

			# Values: "new-pane", "replace-pane", "new-window"
			[sidebar]
			buffer_action = "replace-pane"
			buffer_focused_action = "close-pane"

			[buffer.server_messages.join]
			smart = 180

			[buffer.server_messages.part]
			smart = 180

			[buffer.server_messages.quit]
			smart = 180

			[buffer.server_messages.topic]
			enabled = false

		'';
	};
}
