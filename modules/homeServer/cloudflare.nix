{...}: {
  flake.nixosModules.cloudflare = {config, ...}: {
    sops.secrets."cloudflareTunnelhomeLab1" = {};
    services.cloudflared = {
      enable = true;
      tunnels = {
        "7fa77531-bf82-4583-818d-51a588c68614" = {
          credentialsFile = "${config.sops.secrets."cloudflareTunnelhomeLab1".path}";
          default = "http_status:404";
          ingress = {
            "server1.odza.dev" = "ssh://127.0.0.1:22";
            "supernote.odza.dev" = "http://127.0.0.1:8081";
            "miniflux.odza.dev" = "http://127.0.0.1:8080";
            "vaultwarden.odza.dev" = "http://127.0.0.1:8222";
          };
        };
      };
    };
  };
}
