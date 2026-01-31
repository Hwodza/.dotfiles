{
  pkgs,
  config,
  lib,
  ...
}:
{
  systemd.user = {
    services.wallpaper-refresh = {
      Unit = {
        Description = "Refresh wallpaper";
        After = [
          # "graphical-session.target"
          # # "hyprpaper.service"
          # "hyprland-session.target"
          "default.target"
        ];
        # Wants = [ "hyprpaper.service" ];
        PartOf = [ "hyprland-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "wallpaper-refresh" ''
          mkdir -p "${config.my.variables.wallpaper-dir-path}"
          ${pkgs.curl}/bin/curl -o "${config.my.variables.wallpaper-path}" -L "https://picsum.photos/3840/2160" 
        '';
      };
      Install.WantedBy = [
        "default.target"
        # "hyprpaper.service"
      ];
    };
    timers.wallpaper-refresh = {
      Unit = {
        Description = "Timer for refreshing wallpaper";
        After = [
          "default.target"
          "graphical-session.target"
        ];

      };
      Timer = {
        # OnBootSec = "1min";
        # OnCalendar = "Sun *-*-* 00:00:00";
        OnCalendar = "daily";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    # services.blueman-applet = {
    #   Unit = {
    #     Description = "Blueman bluetooth applet";
    #     After = [
    #       "default.target"
    #       "graphical.target"
    #     ];
    #   };
    #   Service = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.blueman}/bin/blueman-applet";
    #     Restart = "always";
    #   };
    #   Install = {
    #     WantedBy = [ "default.target" ];
    #   };
    # };

    # services.nm-applet = {
    #   Unit = {
    #     Description = "NetworkManager system tray applet";
    #     After = [
    #       "graphical-session.target"
    #       "default.target"
    #     ];
    #   };
    #   Service = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    #     Restart = "always";
    #   };
    #   Install = {
    #     WantedBy = [
    #       "graphical-session.target"
    #       "default.target"
    #     ];
    #   };
    # };
  };

}
