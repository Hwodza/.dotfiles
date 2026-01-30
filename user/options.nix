{ lib, config, ... }:
{
  options.my = {
    variables = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Shared general variables";
    };
  };
  config.my = {
    variables = {
      wallpaper-path = "${config.xdg.dataHome}/wallpapers/wallpaper.jpeg";
      wallpaper-dir-path = "${config.xdg.dataHome}/wallpapers/";
    };
  };
}
