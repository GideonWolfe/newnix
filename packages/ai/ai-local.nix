{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [
    # These packages are all programs for designing and running LLMs locally
    # WARNING: these are large packages.

    pkgs.open-interpreter # BUG: crashing
    pkgs.cherry-studio
    pkgs.open-webui # NOTE: this is a big one, maybe enable conditionally
    pkgs.alpaca # GTK LLM GUI
    #(pkgs.alpaca.override { ollama = pkgs.ollama-rocm; })
    pkgs.lmstudio # LLM GUI # also big!
  ];
}
