{self, ...}: {
  flake.nixosModules.homeLab = {pkgs, ...}: {
    imports = [
      self.nixosModules.homeLab-cloudflare
      self.nixosModules.rclone
      self.nixosModules.miniflux
      self.nixosModules.vaultwarden
    ];
  };

  # flake.nixosModules.caddy = {...}: {
  #   services.caddy = {
  #     enable = true;
  #     virtualHosts = {
  #       "supernote.odza.dev" = {
  #         extraConfig = ''
  #           reverse_proxy http://127.0.0.1:8080
  #         '';
  #       };
  #     };
  #   };
  # };
}
