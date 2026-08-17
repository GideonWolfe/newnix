{
  imports = [
    ./provider.nix
    ./user.nix

    # Sites
    ./sites/home.nix
    ./sites/offsite.nix

    # Clusters
    ./clusters/home.nix

    # Rack roles
    ./rack_roles/compute.nix
    ./rack_roles/network.nix

    # Racks
    ./racks/home-compute-rack.nix
    ./racks/home-network-rack.nix
    ./racks/offsite-compute-rack.nix

    # Manufacturers
    ./manufacturers/mikrotik.nix
    ./manufacturers/lenovo.nix
    ./manufacturers/western_digital.nix
    ./manufacturers/ugreen.nix
    ./manufacturers/beelink.nix
    ./manufacturers/deskpi.nix
    ./manufacturers/smlight.nix
    ./manufacturers/retroid.nix
    ./manufacturers/google.nix

    # Device types
    ./device_types/mikrotik_rb5009.nix
    ./device_types/mikrotik_css318.nix
    ./device_types/mikrotik_hapax2.nix
    ./device_types/lenovo_m900.nix
    ./device_types/ugreen_dxp4800plus.nix
    ./device_types/ugreen_dxp2800.nix
    ./device_types/beelink_u59.nix
    ./device_types/deskpi_patch_panel_halfu.nix
    ./device_types/deskpi_patch_panel_1u.nix
    ./device_types/slzb06mu.nix
    ./device_types/retroid_pocket6.nix
    ./device_types/pixel_9a.nix

    # Device roles
    ./device_roles/router.nix
    ./device_roles/switch.nix
    ./device_roles/access_point.nix
    ./device_roles/compute.nix
    ./device_roles/patch_panel.nix
    ./device_roles/iot_coordinator.nix
    ./device_roles/handheld.nix

    # Devices
    ./devices/mikrotik_rb5009.nix
    ./devices/mikrotik_css318.nix
    ./devices/mikrotik_hapax2.nix
    ./devices/lenovo_m900_1.nix
    ./devices/lenovo_m900_2.nix
    ./devices/lenovo_m900_3.nix
    ./devices/ugreen_dxp4800plus.nix
    ./devices/ugreen_dxp2800.nix
    ./devices/beelink_u59.nix
    ./devices/deskpi_patch_panel_halfu.nix
    ./devices/deskpi_patch_panel_1u.nix
    ./devices/slzb06.nix
    ./devices/retroidpocket6.nix
    ./devices/pixel9a.nix

    # Virtual machines
    ./vms/vm-media.nix
    ./vms/vm-ingress.nix

    # Services
    ./services/jellyfin.nix
    ./services/navidrome.nix
    ./services/slskd.nix
    ./services/soulsync.nix
    ./services/nzbget.nix
    ./services/radarr.nix
    ./services/sonarr.nix
    ./services/prowlarr.nix
    ./services/recyclarr.nix
    ./services/seerr.nix
  ];
}
