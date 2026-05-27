{inputs, ...}: {
  flake.nixosModules.hypr = {
    pkgs,
    lib,
    config,
    ...
  }: {
    nixpkgs.overlays = [
      (_final: prev: {
        hyprland-workspace2d = inputs.hyprland-workspace2d.packages.${prev.system}.workspace2d;
      })
    ];

    programs.hyprland = {
      enable = true;
      package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.myHyprland;
    };

    environment.systemPackages = [
      pkgs.hyprland-workspace2d
    ];
  };
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.myHyprland = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;
      runtimeInputs = [
        self'.packages.myNoctalia
      ];
      flags = {
        "--config" = "/home/henry/.dotfiles/modules/hypr/hyprland.lua";
      };
    };
  };
}
