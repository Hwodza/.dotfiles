{...}: {
  flake.nixosModules.vaultwarden = {config, pkgs, ...}: {
    sops.secrets."vaultwarden_ADMIN_TOKEN" = {};
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";
        WEBSOCKET_ENABLED = true;
        SIGNUPS_ALLOWED = false;
      };
      environmentFile = config.sops.secrets."vaultwarden_ADMIN_TOKEN".path;
    };
    environment.systemPackages = with pkgs; [
      vaultwarden
    ];
  };
}
