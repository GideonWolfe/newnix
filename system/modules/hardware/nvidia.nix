{ config, lib, pkgs, ... }:

# Proprietary NVIDIA driver + PRIME render offload for NVIDIA Optimus laptops
# (e.g. the Dell XPS 15 9510 / ares: Intel Xe iGPU + RTX 3050 Mobile dGPU).
#
# By default such laptops render on the Intel iGPU and the discrete NVIDIA card
# sits idle. With offload configured the dGPU stays powered down until a program
# is explicitly launched on it via the `nvidia-offload` wrapper - keeping heat
# and battery drain low while still giving games the full discrete GPU.
{
  # Use the proprietary NVIDIA driver instead of the open-source nouveau one.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Userspace graphics stack (Vulkan/OpenGL ICDs, VA-API, etc.).
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit games and Proton need the 32-bit libraries
  };

  hardware.nvidia = {
    # Required for a working modern setup and for Wayland sessions (niri).
    modesetting.enable = true;

    # Open kernel modules are NVIDIA's recommendation for Turing and newer.
    # The RTX 3050 is Ampere, so this is supported; flip to false to fall back
    # to the legacy proprietary modules if anything misbehaves.
    open = true;

    # Installs nvidia-settings.
    nvidiaSettings = true;

    # Track the stable driver built against the running kernel.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement = {
      enable = true;
      # Fully power the dGPU down when unused (offload mode, Turing+ only).
      # Ideal for a laptop: the card draws ~0W until a game asks for it.
      finegrained = true;
    };

    prime = {
      # Bus IDs confirmed on ares via `lspci -k`.
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      offload = {
        enable = true;
        # Provides the `nvidia-offload` command wrapper.
        enableOffloadCmd = true;
      };
    };
  };
}
