{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.hypr = {pkgs, lib, ...}: {
    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
    };
  };
}
