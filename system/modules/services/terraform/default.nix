{
    imports = [
        # Set up the local environment for my terraform infra
        ./terraform_environment.nix
        # Make sure we have the necessary secrets in place for terraform to authenticate with various platforms
        ./secrets_terraform.nix
    ];
}