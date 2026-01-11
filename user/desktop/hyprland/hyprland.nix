{
  pkgs,
  lib,
  config,
  ...
}: let
  workspace2d = "${lib.getBin pkgs.hyprland-workspace2d}/bin/workspace2d";
  hyprPath = "${config.home.homeDirectory}/.dotfiles/user/desktop/hyprland/hypr";
in {
  home.sessionVariables = {
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    XDG_PICTURES_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  };
  # wayland.windowManager.hyprland.enable = true;
  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink hyprPath;
}
