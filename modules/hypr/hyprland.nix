{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.hyprland = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;
      flags = {
        "--config" = "/home/henry/.dotfiles/modules/hypr/hyprland.lua";
      };
    };
  };
}
