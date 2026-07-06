{self, ...}: {
  flake.homeModules.kitty = {
    pkgs,
    lib,
    ...
  }: let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in {
    programs.kitty = {
      enable = true;
      package = null;
      shellIntegration.mode = null;
      settings = {
        shell = lib.getExe selfpkgs.environment;

        auto_reload_config = -1;
        enable_audio_bell = "no";

        cursor_text_color = "background";

        allow_remote_control = "yes";
        shell_integration = "disabled";

        cursor_trail = 3;
      };

      extraConfig = ''
        include ~/.local/state/theme/current/kitty.conf
      '';

      keybindings = {
        "alt+1" = "goto_tab 1";
        "alt+2" = "goto_tab 2";
        "alt+3" = "goto_tab 3";
        "alt+4" = "goto_tab 4";
        "alt+5" = "goto_tab 5";
        "alt+6" = "goto_tab 6";
        "alt+7" = "goto_tab 7";
        "alt+8" = "goto_tab 8";
        "alt+9" = "goto_tab 9";
        "ctrl+shift+w" = "close_tab";
        "ctrl+t" = "new_tab_with_cwd";
        "ctrl+shift+t" = "new_tab";
      };
    };
  };
}
