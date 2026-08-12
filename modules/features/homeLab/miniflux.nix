{...}: {
  flake.nixosModules.miniflux = {config, ...}: {
    sops.secrets."miniflux" = {};
    services.miniflux = {
      enable = true;
      adminCredentialsFile = "${config.sops.secrets."miniflux".path}";
    };
  };
}
