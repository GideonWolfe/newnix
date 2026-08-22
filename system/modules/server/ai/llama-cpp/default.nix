{
  imports = [
    # The llama-swap systemd service (fronts llama-server, hot-swaps models)
    ./llama-swap.nix
    # Mirrors the canonical GGUF library on the NAS down to the local NVMe
    # cache so model swaps are fast, while the NAS stays the source of truth.
    ./model-sync.nix
  ];
}
