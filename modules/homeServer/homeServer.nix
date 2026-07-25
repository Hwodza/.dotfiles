{self, ...}: {
  flake.nixosModules.homeServer = {pkgs, ...}: {
    imports = [
      self.nixosModules.cloudflare
      self.nixosModules.rclone
      self.nixosModules.miniflux
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
