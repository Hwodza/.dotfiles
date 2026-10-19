{...}: {
  flake.nixosModules.microbin = {config, ...}: {
    sops.secrets."microbin" = {};
    services.microbin = {
      enable = true;
      passwordFile = "${config.sops.secrets."microbin".path}";
      settings = {
        MICROBIN_BIND = "0.0.0.0";
        MICROBIN_PORT = "8090";
        MICROBIN_ENCRYPTION_CLIENT_SIDE = true;
        MICROBIN_ENCRYPTION_SERVER_SIDE = true;
        MICROBIN_HASH_IDS = true;
        MICROBIN_DISABLE_TELEMETRY = true;
      };
    };
  };
}
