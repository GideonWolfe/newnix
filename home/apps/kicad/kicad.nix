{ pkgs, lib, config, ... }:

with config.lib.stylix.colors;
let
  base0 = "rgb(${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b})";
  base1 = "rgb(${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b})";
  base2 = "rgb(${base02-rgb-r}, ${base02-rgb-g}, ${base02-rgb-b})";
  base3 = "rgb(${base03-rgb-r}, ${base03-rgb-g}, ${base03-rgb-b})";
  base4 = "rgb(${base04-rgb-r}, ${base04-rgb-g}, ${base04-rgb-b})";
  base5 = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
  base6 = "rgb(${base06-rgb-r}, ${base06-rgb-g}, ${base06-rgb-b})";
  base7 = "rgb(${base07-rgb-r}, ${base07-rgb-g}, ${base07-rgb-b})";
  base8 = "rgb(${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b})";
  base9 = "rgb(${base09-rgb-r}, ${base09-rgb-g}, ${base09-rgb-b})";
  baseA = "rgb(${base0A-rgb-r}, ${base0A-rgb-g}, ${base0A-rgb-b})";
  baseB = "rgb(${base0B-rgb-r}, ${base0B-rgb-g}, ${base0B-rgb-b})";
  baseC = "rgb(${base0C-rgb-r}, ${base0C-rgb-g}, ${base0C-rgb-b})";
  baseD = "rgb(${base0D-rgb-r}, ${base0D-rgb-g}, ${base0D-rgb-b})";
  baseE = "rgb(${base0E-rgb-r}, ${base0E-rgb-g}, ${base0E-rgb-b})";
  baseF = "rgb(${base0F-rgb-r}, ${base0F-rgb-g}, ${base0F-rgb-b})";
in {
  xdg.configFile.kicad-theme = {
    enable = true;
    target = "kicad/10.0/colors/stylix.json";

    text = ''
      {
        "3d_viewer": {
          "background_bottom": "${base4}",
          "background_top": "${base4}",
          "board": "rgba(${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b}, 0.902)",
          "copper": "${base9}",
          "silkscreen_bottom": "${base4}",
          "silkscreen_top": "${base4}",
          "soldermask_bottom": "rgba(${base03-rgb-r}, ${base03-rgb-g}, ${base03-rgb-b}, 0.831)",
          "soldermask_top": "rgba(${base03-rgb-r}, ${base03-rgb-g}, ${base03-rgb-b}, 0.831)",
          "solderpaste": "${base4}"
        },
        "board": {
          "anchor": "${base9}",
          "aux_items": "${base4}",
          "b_adhes": "${base6}",
          "b_crtyd": "${baseB}",
          "b_fab": "${base3}",
          "b_mask": "rgba(${base0C-rgb-r}, ${base0C-rgb-g}, ${base0C-rgb-b}, 0.40)",
          "b_paste": "rgba(${base0C-rgb-r}, ${base0C-rgb-g}, ${base0C-rgb-b}, 0.90)",
          "b_silks": "${base4}",
          "background": "${base0}",
          "cmts_user": "${base4}",
          "conflicts_shadow": "rgba(${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b}, 0.50)",
          "copper": {
            "b": "${baseC}",
            "f": "${base9}",
            "in1": "${baseA}",
            "in10": "${base8}",
            "in11": "${baseC}",
            "in12": "${baseD}",
            "in13": "${baseA}",
            "in14": "${base9}",
            "in15": "${baseB}",
            "in16": "${base8}",
            "in17": "${baseC}",
            "in18": "${baseD}",
            "in19": "${baseA}",
            "in2": "${base9}",
            "in20": "${baseB}",
            "in21": "${base8}",
            "in22": "${baseC}",
            "in23": "${baseD}",
            "in24": "${baseA}",
            "in25": "${base9}",
            "in26": "${baseB}",
            "in27": "${base8}",
            "in28": "${baseC}",
            "in29": "${baseD}",
            "in3": "${baseB}",
            "in30": "${baseA}",
            "in4": "${base8}",
            "in5": "${baseC}",
            "in6": "${baseD}",
            "in7": "${baseA}",
            "in8": "${base9}",
            "in9": "${baseB}"
          },
          "cursor": "${base6}",
          "drc_error": "rgba(${base08-rgb-r}, ${base08-rgb-g},${base08-rgb-b}, 0.80)",
          "drc_exclusion": "rgba(${base0C-rgb-r}, ${base0C-rgb-g},${base0C-rgb-b}, 0.80)",
          "drc_warning": "rgba(${base0A-rgb-r}, ${base0A-rgb-g},${base0A-rgb-b}, 0.80)",
          "dwgs_user": "${base4}",
          "eco1_user": "${base9}",
          "eco2_user": "${baseA}",
          "edge_cuts": "${base5}",
          "f_adhes": "${base9}",
          "f_crtyd": "${base9}",
          "f_fab": "${base4}",
          "f_mask": "rgba(${base0A-rgb-r}, ${base0A-rgb-g},${base0A-rgb-b}, 0.40)",
          "f_paste": "rgba(${base0B-rgb-r}, ${base0B-rgb-g},${base0B-rgb-b}, 0.40)",
          "f_silks": "${base4}",
          "footprint_text_invisible": "${base4}",
          "grid": "${base4}",
          "grid_axes": "${base4}",
          "locked_shadow": "rgba(${base0E-rgb-r}, ${base0E-rgb-g},${base0E-rgb-b}, 0.50)",
          "margin": "${base7}",
          "pad_plated_hole": "${base9}",
          "pad_through_hole": "${baseA}",
          "page_limits": "${base4}",
          "plated_hole": "${base8}",
          "ratsnest": "rgba(${base09-rgb-r}, ${base09-rgb-g},${base09-rgb-b}, 0.50)",
          "user_1": "${base4}",
          "user_2": "${base9}",
          "user_3": "${base6}",
          "user_4": "${baseA}",
          "user_5": "${base3}",
          "user_6": "rgb(89, 148, 220)",
          "user_7": "rgb(180, 219, 210)",
          "user_8": "rgb(216, 200, 82)",
          "user_9": "rgb(232, 178, 167)",
          "via_blind_buried": "${baseA}",
          "via_hole": "${baseA}",
          "via_micro": "${baseB}",
          "via_through": "${base4}",
          "worksheet": "${base5}"
        },
        "gerbview": {
          "axes": "${base4}",
          "background": "${base0}",
          "dcodes": "${base1}",
          "grid": "${base3}",
          "layers": [
            "${base8}", "${base9}", "${baseA}", "${baseB}", "${baseC}", "${baseD}", "${baseE}", "${baseF}",
            "${base8}", "${base9}", "${baseA}", "${baseB}", "${baseC}", "${baseD}", "${baseE}", "${baseF}",
            "${base8}", "${base9}", "${baseA}", "${baseB}", "${baseC}", "${baseD}", "${baseE}", "${baseF}",
            "${base8}", "${base9}", "${baseA}", "${baseB}", "${baseC}", "${baseD}", "${baseE}", "${baseF}",
            "${base8}", "${base9}", "${baseA}", "${baseB}", "${baseC}", "${baseD}", "${baseE}", "${baseF}",
            "${base8}", "${base9}", "${baseA}", "${baseB}", "${baseC}", "${baseD}", "${baseE}", "${baseF}",
            "${base8}", "${base9}", "${baseA}", "${baseB}", "${baseC}", "${baseD}", "${baseE}", "${baseF}",
            "${base8}", "${base9}", "${baseA}", "${baseB}"
          ],
          "negative_objects": "${base3}",
          "page_limits": "${base3}",
          "worksheet": "${base4}"
        },
        "meta": {
          "name": "Stylix",
          "version": 1
        },
        "schematic": {
          "anchor": "${baseA}",
          "aux_items": "${base4}",
          "background": "${base0}",
          "brightened": "${baseA}",
          "bus": "${baseC}",
          "bus_junction": "${baseB}",
          "component_body": "${base1}",
          "component_outline": "${baseB}",
          "cursor": "${base6}",
          "dnp_marker": "rgba(${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b}, 0.70)",
          "erc_error": "rgba(${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b}, 0.80)",
          "erc_exclusion": "rgba(${base0C-rgb-r}, ${base0C-rgb-g}, ${base0C-rgb-b}, 0.80)",
          "erc_warning": "rgba(${base0A-rgb-r}, ${base0A-rgb-g}, ${base0A-rgb-b}, 0.80)",
          "fields": "${base9}",
          "grid": "${base4}",
          "grid_axes": "${base7}",
          "hidden": "${base4}",
          "hovered": "${baseD}",
          "junction": "${baseA}",
          "label_global": "${base9}",
          "label_hier": "${baseB}",
          "label_local": "${baseD}",
          "netclass_flag": "${base4}",
          "no_connect": "${base8}",
          "note": "${baseA}",
          "note_background": "rgba(${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b}, 0.000)",
          "op_currents": "${base8}",
          "op_voltages": "${base8}",
          "override_item_colors": false,
          "page_limits": "${base4}",
          "pin": "${baseB}",
          "pin_name": "${baseA}",
          "pin_number": "${baseC}",
          "private_note": "${base7}",
          "reference": "${baseA}",
          "shadow": "rgba(${base04-rgb-r}, ${base04-rgb-g}, ${base04-rgb-b}, 0.53)",
          "sheet": "${baseC}",
          "sheet_background": "rgba(${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b}, 0.000)",
          "sheet_fields": "${baseA}",
          "sheet_filename": "${baseA}",
          "sheet_label": "${base6}",
          "sheet_name": "${baseA}",
          "value": "${baseD}",
          "wire": "${baseD}",
          "worksheet": "${baseA}"
        }
      }
    '';

  };
}
