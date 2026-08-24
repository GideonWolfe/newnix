{ pkgs, lib, config, osConfig ? { }, ... }:

# Autoconfig for the aichat CLI, pointed at the self-hosted llama-swap endpoint
# on the AI VM. Endpoint is derived from lib/world/services.nix (single source
# of truth), so if the llama-swap IP/port changes, aichat follows.

let
  # llama-swap service from the world config, with a localhost fallback so this
  # module is harmless on a host that doesn't import lib/world.
  llama = osConfig.custom.world.services."llama-swap" or null;
  endpoint =
    if llama != null
    then "${llama.protocol}://${llama.ip}:${toString llama.port}/v1"
    else "http://127.0.0.1:8080/v1";

  # Must match a model id llama-swap advertises at /v1/models.
  defaultModel = "qwen2.5-7b";

  yamlFormat = pkgs.formats.yaml { };
in
{
  # Real YAML via pkgs.formats.yaml. (The previous config used
  # lib.generators.toYAML, which is just toJSON in nixpkgs -- valid YAML, but
  # it renders as JSON. This uses a proper YAML serializer.)
  xdg.configFile.aichat = {
    enable = true;
    target = "aichat/config.yaml";

    source = yamlFormat.generate "aichat-config.yaml" {
      # Client name : model id -- points aichat at the llama-swap default.
      model = "llama-swap:${defaultModel}";
      clients = [{
        type = "openai-compatible";
        name = "llama-swap";
        api_base = endpoint;
        # llama-swap ignores auth, but some aichat versions expect the field.
        api_key = "sk-noauth";
        models = [ { name = defaultModel; } ];
      }];
    };
  };
}
