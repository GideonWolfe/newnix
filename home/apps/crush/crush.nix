{ pkgs, lib, config, osConfig ? { }, ... }:

# Autoconfig for the Crush AI coding TUI, pointed at the self-hosted llama-swap
# endpoint on the AI VM. The crush *package* is installed system-wide in
# packages/ai/ai.nix; this just drops in its config so it works out of the box
# with no first-run wizard.
#
# The endpoint is derived from lib/world/services.nix (single source of truth),
# so if the llama-swap IP/port ever changes, crush follows automatically.

let
  # llama-swap service from the world config. Guard with a fallback so this
  # module is harmless on a host that doesn't import lib/world.
  llama = osConfig.custom.world.services."llama-swap" or null;
  endpoint =
    if llama != null
    then "${llama.protocol}://${llama.ip}:${toString llama.port}/v1"
    else "http://127.0.0.1:8080/v1";

  # Default model both agent roles start on. Must match a model id llama-swap
  # advertises at /v1/models; discover_models picks up the rest for the picker.
  defaultModel = "qwen2.5-7b";

  jsonFormat = pkgs.formats.json { };
in
{
  # Global JSON config at ~/.config/crush/crush.json.
  #
  # NOTE: crush's JSON config is supported-but-deprecated upstream (the newer
  # format is a bash-based `crushrc`). It's used here because its schema is
  # fully specified, generates cleanly via pkgs.formats.json, and -- unlike the
  # documented crushrc builtins -- lets us set the default large/small models
  # declaratively so there's no first-run picker. Migration to crushrc later is
  # trivial if the JSON format is ever dropped.
  xdg.configFile."crush/crush.json".source = jsonFormat.generate "crush.json" {
    "$schema" = "https://charm.land/crush.json";

    providers.llama-swap = {
      name = "llama-swap (self-hosted)";
      # openai-compat: a non-OpenAI server speaking the OpenAI API. llama-swap
      # ignores auth, but crush still wants a non-empty key.
      type = "openai-compat";
      base_url = endpoint;
      api_key = "sk-noauth";
      # Auto-populate the model list from llama-swap's /v1/models, so new
      # models/personas show up in the picker without editing this file.
      discover_models = true;
    };

    # Start both agent roles on a discovered model so crush is ready to chat
    # immediately. Switch models mid-session in the TUI with ctrl+l.
    models = {
      large = { model = defaultModel; provider = "llama-swap"; };
      small = { model = defaultModel; provider = "llama-swap"; };
    };

    options = {
      # Purely-local endpoint: skip crush's Catwalk provider auto-update (it
      # only matters for the cloud provider/model catalog and is just network
      # chatter here).
      disable_provider_auto_update = true;

      # --- Trim prompt-eval load for the CPU-only endpoint ---------------
      # Crush is an agentic coding tool: even a one-word message ships its
      # full system prompt + every built-in tool's JSON schema + LSP
      # diagnostics + context files on EVERY request. On a CPU model that
      # prompt-eval can exceed crush's request timeout, surfacing as
      # "context deadline exceeded" regardless of how short your message is.
      # These knobs cut what gets sent without breaking crush outright.

      # Don't auto-spawn LSP servers; their diagnostics are injected as context.
      auto_lsp = false;

      # Skip the extra "small model" summarization calls -- slow on CPU and
      # they re-send the whole conversation each time.
      disable_auto_summarize = true;

      # Stop injecting context files (CRUSH.md / AGENTS.md) into every prompt.
      # global_context_paths defaults to ~/.config/crush/CRUSH.md + AGENTS.md;
      # empty both so nothing extra is prepended.
      context_paths = [ ];
      global_context_paths = [ ];

      # NUCLEAR OPTION (commented): strip crush's built-in tools, which are the
      # single biggest chunk of the system prompt. This is what actually makes
      # a one-word turn cheap. BUT it neuters crush's ability to edit files /
      # run commands -- at that point it's just a slow chat client and aichat
      # or Open WebUI is the better tool. Verify exact names against
      # `crush --help` / the tool list before enabling.
      # disabled_tools = [
      #   "bash" "view" "edit" "write" "ls" "grep" "glob"
      #   "fetch" "download" "sourcegraph" "diagnostics"
      # ];
    };
  };
}
