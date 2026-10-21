{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.plasma-bigscreen = {
    # inputs,
    pkgs,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config = pkgs.config;
    };
  in {
    environment.systemPackages = [
      unstablePkgs.kdePackages.plasma-workspace
      unstablePkgs.kdePackages.plasma-bigscreen
    ];

    programs.kdeconnect = {
      enable = true;
      package = lib.mkForce unstablePkgs.kdePackages.kdeconnect-kde;
    };
    services.desktopManager.plasma6.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
