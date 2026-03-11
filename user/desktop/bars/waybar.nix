{
  config,
  ...
}:
let
  waybarPath = "${config.home.homeDirectory}/.dotfiles/user/desktop/bars/waybar";
in
{
  # wayland.windowManager.hyprland.enable = true;
  xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink waybarPath;
}
