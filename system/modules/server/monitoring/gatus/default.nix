{
    imports = [
        # Main Gatus module that runs the container and exposes the service
        ./gatus.nix
        # The list of endpoints to monitor, derived from the world services
        ./endpoints.nix
        # Stylix-derived custom-css theme for the dashboard
        ./theme.nix
        # Prometheus monitoring configuration for Gatus
        ./gatus-monitoring.nix
    ];
}