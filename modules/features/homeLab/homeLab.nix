{self, ...}: {
  flake.nixosModules.homeLab = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.homeLab-cloudflare
      self.nixosModules.rclone
      self.nixosModules.miniflux
      self.nixosModules.vaultwarden
    ];
    home-manager.users.${config.preferences.user.name}.imports = [
      self.homeModules.ssh
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
