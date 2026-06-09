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
  # flake.nixosModules.hypr = {
  #   pkgs,
  #   lib,
  #   config,
  #   ...
  # }: {
  #   options.my.hyprland.package = lib.mkOption {
  #     type = lib.types.package;
  #     default = pkgs.hyprland;
  #     description = "Hyprland package to use. Override with the wrapped build.";
  #   };
  #
  #   config = {
  #     nixpkgs.overlays = [
  #       (_final: prev: {
  #         hyprland-workspace2d =
  #           inputs.hyprland-workspace2d.packages.${prev.system}.workspace2d;
  #       })
  #     ];
  #
  #     programs.hyprland = {
  #       enable = true;
  #       package = config.my.hyprland.package;
  #     };
  #
  #     environment.systemPackages = [pkgs.hyprland-workspace2d];
  #   };
  # };
  #
  # perSystem = {
  #   pkgs,
  #   lib,
  #   self',
  #   ...
  # }: {
  #   packages.myHyprland = inputs.wrappers.lib.wrapPackage {
  #     inherit pkgs;
  #     package = pkgs.hyprland;
  #     # binName = "Hyprland";
  #     runtimeInputs = [self'.packages.myNoctalia];
  #     env.TERMINAL = lib.getExe self'.packages.terminal;
  #     flags."--config" = "/home/henry/.dotfiles/modules/hypr/hyprland.lua";
  #   };
  # };
}
