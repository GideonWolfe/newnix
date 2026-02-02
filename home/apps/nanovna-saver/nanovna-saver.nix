
{ pkgs, lib, config, ... }:

with config.lib.stylix.colors;
let
	# Convert RGBA components to strings explicitly to satisfy INI generation
	rgba = r: g: b: a: "(${builtins.toString r}, ${builtins.toString g}, ${builtins.toString b}, ${builtins.toString a})";

	background = rgba base00-rgb-r base00-rgb-g base00-rgb-b 255;
	foreground = rgba base05-rgb-r base05-rgb-g base05-rgb-b 255;
	bands = rgba base03-rgb-r base03-rgb-g base03-rgb-b 48;
	reference = rgba base0D-rgb-r base0D-rgb-g base0D-rgb-b 96;
	referenceSecondary = rgba base0D-rgb-r base0D-rgb-g base0D-rgb-b 48;
	sweep = rgba base0B-rgb-r base0B-rgb-g base0B-rgb-b 255;
	sweepSecondary = rgba base0E-rgb-r base0E-rgb-g base0E-rgb-b 255;
	swr = rgba base08-rgb-r base08-rgb-g base08-rgb-b 180;
	text = foreground;

	marker0 = rgba base04-rgb-r base04-rgb-g base04-rgb-b 255;
	marker1 = rgba base08-rgb-r base08-rgb-g base08-rgb-b 255;
	marker2 = rgba base0B-rgb-r base0B-rgb-g base0B-rgb-b 255;
	marker3 = rgba base0D-rgb-r base0D-rgb-g base0D-rgb-b 255;
	marker4 = rgba base0C-rgb-r base0C-rgb-g base0C-rgb-b 255;
	marker5 = rgba base0E-rgb-r base0E-rgb-g base0E-rgb-b 255;
	marker6 = rgba base0A-rgb-r base0A-rgb-g base0A-rgb-b 255;
	marker7 = rgba base06-rgb-r base06-rgb-g base06-rgb-b 255;

	chartColors = {
		background = "\"${background}\"";
		bands = "\"${bands}\"";
		foreground = "\"${foreground}\"";
		reference = "\"${reference}\"";
		reference_secondary = "\"${referenceSecondary}\"";
		sweep = "\"${sweep}\"";
		sweep_secondary = "\"${sweepSecondary}\"";
		swr = "\"${swr}\"";
		text = "\"${text}\"";
	};

	markers = {
		color_0 = "\"${marker0}\"";
		color_1 = "\"${marker1}\"";
		color_2 = "\"${marker2}\"";
		color_3 = "\"${marker3}\"";
		color_4 = "\"${marker4}\"";
		color_5 = "\"${marker5}\"";
		color_6 = "\"${marker6}\"";
		color_7 = "\"${marker7}\"";
		colored_names = "True";
	};

	gui = {
		custom_colors = "True";
		dark_mode = "True";
	};

	iniFragment = lib.generators.toINI {} {
		CHART_COLORS = chartColors;
		GUI = gui;
		MARKERS = markers;
	};

	configPath = "${config.xdg.configHome}/NanoVNASaver/NanoVNASaver.conf";
in {
	# Generate an INI fragment with Stylix colors and merge it into the user's
	# mutable NanoVNA-Saver config. The file remains writable by the app.
	home.activation.nanovnaSaverTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
		target=${lib.escapeShellArg configPath}
		mkdir -p "$(dirname "$target")"
		if [ ! -f "$target" ]; then
			install -Dm644 /dev/null "$target"
		fi
		${pkgs.crudini}/bin/crudini --merge "$target" <<'EOF'
${iniFragment}
EOF
	'';
}
