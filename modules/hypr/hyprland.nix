{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.hyprland = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;
      flags = {
        "--config" = "~/.dotfiles/modules/hypr/hyprland.lua";
      };
    };
  };
}
