{
  pkgs,
  lib,
  config,
  ...
}:
let
  ironbarPath = "${config.home.homeDirectory}/.dotfiles/user/desktop/ironbar/ironbar";
in
{
  # wayland.windowManager.hyprland.enable = true;
  xdg.configFile."ironbar".source = config.lib.file.mkOutOfStoreSymlink ironbarPath;
}
