{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

{
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        userSettings = {
          # Tell GH Copilot to use our custom instructions files
          "github.copilot.chat.codeGeneration.useInstructionFiles" = true;
          # Tell VS Code to ignore UID and import files produced by Godot (we shouldn't touch them)
          "files.exclude" = {
            "**/*.gd.uid" = true;
            "**/*.import" = true;
          };
          # Stylix themes all chrome surfaces (sidebar, activity/status bar, panel,
          # tab headers, title bar) with base01. Since the base16 spec fix made
          # base01 lighter than the editor's base00, these panes now look brighter
          # than the code window. Pin them back to base00 for a uniform dark look.
          # Uses stylix color vars so it tracks whatever scheme is active.
          "workbench.colorCustomizations" = {
            "sideBar.background" = base00;
            "sideBarSectionHeader.background" = base00;
            "activityBar.background" = base00;
            "statusBar.background" = base00;
            "statusBar.noFolderBackground" = base00;
            "panel.background" = base00;
            "titleBar.activeBackground" = base00;
            "titleBar.inactiveBackground" = base00;
            "editorGroupHeader.tabsBackground" = base00;
            "editorGroupHeader.noTabsBackground" = base00;
            "breadcrumb.background" = base00;
            "tab.inactiveBackground" = base00;
            "tab.unfocusedInactiveBackground" = base00;
          };
        };
        # enableUpdateCheck = true;
        # enableExtensionUpdateCheck = true;
        # extensions = with pkgs.vscode-extensions; [
        #   golang.go # Golang
        #   vue.volar # Golang
        #   mattn.lisp # Lisp
        #   twxs.cmake # Cmake
        #   sumneko.lua # Lua
        #   bbenoist.nix # Nix
        #   zainchen.json # Json
        #   vscodevim.vim # Vim
        #   shopify.ruby-lsp # Ruby
        #   tomoki1207.pdf # PDF Preview
        #   redhat.ansible # Ansible
        #   redhat.vscode-xml # XML
        #   redhat.vscode-yaml # YAML
        #   ms-python.debugpy # Python debugger
        #   ms-pyright.pyright # Python Linter
        #   ms-toolsai.jupyter # Juptyter
        #   ms-vscode.hexeditor # Hex editor
        #   ms-vscode.powershell # Powershell
        #   ms-dotnettools.csharp # C#
        #   eugleo.magic-racket # Racket
        #   tamasfe.even-better-toml # TOML
        #   github.copilot # Github Copilot
        #   #github.copilot-chat # Github Copilot Chat #BUG: OUT OF DATE
        #   geequlim.godot-tools
        # ];
      };
    };
  };
}
