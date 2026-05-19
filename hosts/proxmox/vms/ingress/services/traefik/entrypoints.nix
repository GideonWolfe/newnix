{
  services.traefik.staticConfigOptions.entryPoints = {

    http = {
      address = ":80";
      forwardedHeaders.insecure = true;
      # Redirect all HTTP traffic to HTTPS
      http.redirections.entryPoint = {
        to = "https";
        scheme = "https";
      };
    };

    # HTTPS entrypoint for services
    https = {
      address = ":443";
      forwardedHeaders.insecure = true;
    };

  };
}

