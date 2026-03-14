{
  pkgs,
  config,
  lib,
  ...
}:
let
  wallpaperScript = pkgs.writeShellScript "apod-wallpaper" ''
    set -euo pipefail

    WALL_DIR="${config.my.variables.wallpaper-dir-path}"
    FINAL="${config.my.variables.wallpaper-path}"

    mkdir -p "$WALL_DIR"

    JSON=$(${pkgs.curl}/bin/curl -s "https://api.nasa.gov/planetary/apod?api_key=HBfXo50oP9KB4EDEzCPAIhMVDhFerv8oeB8q99SD")

    MEDIA_TYPE=$(echo "$JSON" | ${pkgs.jq}/bin/jq -r '.media_type')
    [ "$MEDIA_TYPE" != "image" ] && exit 0

    DATE=$(echo "$JSON" | ${pkgs.jq}/bin/jq -r '.date')
    URL=$(echo "$JSON" | ${pkgs.jq}/bin/jq -r '.hdurl // .url')

    RAW="$WALL_DIR/$DATE-raw.jpg"

    if [ ! -f "$RAW" ]; then
      ${pkgs.curl}/bin/curl -L "$URL" -o "$RAW"
    fi

    RES=$(${pkgs.hyprland}/bin/hyprctl monitors -j \
      | ${pkgs.jq}/bin/jq -r '.[0] | "\(.width)x\(.height)"')

    ${pkgs.imagemagick}/bin/magick "$RAW" \
      -resize "$RES^" \
      -gravity center \
      -extent "$RES" \
      "$FINAL"

    ${pkgs.hyprland}/bin/hyprctl hyprpaper reload ,"$FINAL" || true
  '';
in
{
  systemd.user.services.apod-wallpaper = {
    Unit = {
      Description = "NASA APOD Wallpaper";
      After = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = wallpaperScript;
    };
  };

  systemd.user.timers.apod-wallpaper = {
    Unit.Description = "Daily APOD Wallpaper Refresh";

    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };

    Install.WantedBy = [ "timers.target" ];
  };
  # systemd.user = {
  #   services.wallpaper-refresh = {
  #     Unit = {
  #       Description = "Refresh wallpaper";
  #       After = [
  #         # "graphical-session.target"
  #         # # "hyprpaper.service"
  #         # "hyprland-session.target"
  #         "default.target"
  #       ];
  #       # Wants = [ "hyprpaper.service" ];
  #       PartOf = [ "hyprland-session.target" ];
  #     };
  #     Service = {
  #       Type = "oneshot";
  #       ExecStart = pkgs.writeShellScript "wallpaper-refresh" ''
  #         mkdir -p "${config.my.variables.wallpaper-dir-path}"
  #         JSON=$(${pkgs.curl}/bin/curl -s "https://api.nasa.gov/planetary/apod?api_key=HBfXo50oP9KB4EDEzCPAIhMVDhFerv8oeB8q99SD")
  #
  #         URL=$(echo "$JSON" | ${pkgs.jq}/bin/jq -r '.hdurl // .url')
  #
  #         ${pkgs.curl}/bin/curl -L "$URL" -o "${config.my.variables.wallpaper-path}"
  #       '';
  #     };
  #     Install.WantedBy = [
  #       "default.target"
  #       # "hyprpaper.service"
  #     ];
  #   };
  #   timers.wallpaper-refresh = {
  #     Unit = {
  #       Description = "Timer for refreshing wallpaper";
  #       After = [
  #         "default.target"
  #         "graphical-session.target"
  #       ];
  #
  #     };
  #     Timer = {
  #       # OnBootSec = "1min";
  #       # OnCalendar = "Sun *-*-* 00:00:00";
  #       OnCalendar = "daily";
  #       Persistent = true;
  #     };
  #     Install.WantedBy = [ "timers.target" ];
  #   };

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
  # };

}
