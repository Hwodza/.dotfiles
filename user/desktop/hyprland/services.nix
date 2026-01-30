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
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "wallpaper-refresh" ''
          	    mkdir -p "${config.my.variables.wallpaper-dir-path}"
          	      ${pkgs.curl}/bin/curl -o "${config.my.variables.wallpaper-path}" -L "https://picsum.photos/3840/2160" 
          	    hyprctl hyprpaper preload "${config.my.variables.wallpaper-path}"
          	    hyprctl hyprpaper wallpaper ,"${config.my.variables.wallpaper-path}"
        '';
      };
    };
    timers.wallpaper-refresh = {
      Unit = {
        Description = "Timer for refreshing wallpaper";
        After = [ "graphical-session.target" ];
      };
      Timer = {
        OnBootSec = "1min";
        OnCalendar = "Sun *-*-* 00:00:00";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    services.blueman-applet = {
      Unit = {
        Description = "Blueman bluetooth applet";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.blueman}/bin/blueman-applet";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    services.nm-applet = {
      Unit = {
        Description = "NetworkManager system tray applet";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

}
