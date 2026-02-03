{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [
    
    # These packages are all AI utilities for interacting with LLMs.
    # Most of them *can* be pointed at local models, but they don't require or include them

    pkgs.tenere # llm TUI
    pkgs.llm # LLM CLI
    pkgs.tgpt # LLM CLI
    inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.crush
    pkgs.aichat # LLM TUI
    pkgs.shell-gpt # CLI for ChatGPT
    pkgs.newelle
  ];
}
