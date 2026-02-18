{lib, config, ...}:
{
    sops = {
        # Tell SOPS to get secrets from the VM specific file in the same dir
        defaultSopsFile = lib.mkForce ./secrets_media.yaml;
        secrets = {
            "nzbget/env" = { owner = "gideon"; };
            "sonarr/apikey" = { owner = "gideon"; };
        };
        templates = {
            "sonarr-config.xml".content = ''
            <Config>
                <BindAddress>*</BindAddress>
                <Port>${builtins.toString config.custom.world.services.sonarr.port}</Port>
                <LaunchBrowser>True</LaunchBrowser>
                <ApiKey>${config.sops.placeholder."sonarr/apikey"}</ApiKey>
                <Branch>main</Branch>
                <LogLevel>info</LogLevel>
                <UpdateMechanism>Docker</UpdateMechanism>
            </Config>
            '';

            "recyclarr-secrets.yml".content = ''
            sonarr_url: ${config.custom.world.services.sonarr.protocol}://sonarr:${builtins.toString config.custom.world.services.sonarr.port}
            sonarr_apikey: ${config.sops.placeholder."sonarr/apikey"}
            '';
        };
    };
}
