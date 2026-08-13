{self, ...}: {
  flake.nixosModules.tail = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      tailscale
    ];
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };
}
