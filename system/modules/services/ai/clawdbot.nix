{ pkgs, lib, config, ... }:

let
  localaiEnabled = config.virtualisation.oci-containers.containers ? localai;
  localaiBaseUrl = "http://localhost:6767/v1";
in
{
  programs.clawdbot = {
    enable = true;

    #providers.anthropic.apiKeyFile = "/run/agenix/anthropic-api-key";

    settings.models.providers = lib.optionalAttrs localaiEnabled {
      localai = {
        api = "openai-completions";
        baseUrl = localaiBaseUrl;
        apiKey = "localai"; # dummy key, LocalAI doesn't require auth
        models = [{
          id = "gpt-4o";
          name = "GPT-4o (LocalAI)";
          contextWindow = 8192;
        }];
      };
    };

    firstParty = {
      oracle.enable = true;
      sag.enable = true;
    };

    plugins = [
      { source = "github:clawdbot/nix-steipete-tools?dir=tools/summarize"; }
    ];
  };
}
