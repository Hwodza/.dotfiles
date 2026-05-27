{
  inputs,
  ...
}: {
  flake.nixosModules.hypr = {pkgs, ...}: {
    nixpkgs.overlays = [
      (_final: prev: {
        hyprland-workspace2d = inputs.hyprland-workspace2d.packages.${prev.system}.workspace2d;
      })
    ];

    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
    };

    environment.systemPackages = [
      pkgs.hyprland-workspace2d
    ];
  };
}
