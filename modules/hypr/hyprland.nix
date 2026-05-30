{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.hypr = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.my.hyprland.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hyprland;
      description = "Hyprland package to use. Override with the wrapped build.";
    };

    config = {
      nixpkgs.overlays = [
        (_final: prev: {
          hyprland-workspace2d =
            inputs.hyprland-workspace2d.packages.${prev.system}.workspace2d;
        })
      ];

      programs.hyprland = {
        enable = true;
        package = config.my.hyprland.package;
      };

      environment.systemPackages = [pkgs.hyprland-workspace2d];
    };
  };

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.myHyprland = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;
      # binName = "Hyprland";
      runtimeInputs = [self'.packages.myNoctalia];
      flags."--config" = "/home/henry/.dotfiles/modules/hypr/hyprland.lua";
    };
  };
}
