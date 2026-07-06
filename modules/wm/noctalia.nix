{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    baseSettings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
    runtimeSettings = lib.recursiveUpdate baseSettings {
      wallpaper = {
        enabled = false;
        automationEnabled = false;
      };
      colorSchemes = {
        useWallpaperColors = false;
      };
      templates = {
        activeTemplates = [];
        enableUserTheming = false;
      };
      hooks = {
        enabled = false;
        wallpaperChange = "";
        colorGeneration = "";
      };
    };
  in {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      outOfStoreConfig = "/home/henry/.config/noctalia";
      settings = runtimeSettings;
      colors = self.theme.noctaliaColors;
    };
  };
}
