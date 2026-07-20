{
  self,
  inputs,
  ...
}: {
  flake.homeModules.hypr = {
    pkgs,
    config,
    ...
  }: let
    hyprPath = "${config.home.homeDirectory}/.dotfiles/modules/wm/hypr";
    system = pkgs.stdenv.hostPlatform.system;
    selfPkgs = self.packages.${system};
    hyprlandPkgs = import inputs.nixpkgs-hyprland {
      inherit system;
      config = pkgs.config;
    };
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config = pkgs.config;
    };
  in {
    home.packages = with pkgs; [
      rofi
      unstablePkgs.nwg-displays
      selfPkgs.myNoctalia
      jq
      hypridle
      hyprlock
    ];
    home.file.".config/rofi/config.rasi".source = ./rofi.config.rasi;
    wayland.windowManager.hyprland = {
      enable = true;
      package = hyprlandPkgs.hyprland;
      portalPackage = hyprlandPkgs.xdg-desktop-portal-hyprland;
      extraConfig = ''
        dofile("${hyprPath}/hyprland.lua")
      '';
    };
  };
}
