{
  pkgs,
  lib,
  system,
  ...
}: {
  services.hypridle = {
    enable = true;
  #   settings = {
  #     general = {
  #       lock_cmd = "pidof hyprlock || hyprlock";
  #       before_sleep_cmd = "loginctl lock-session"; # lock before suspend
  #       after_sleep_cmd = "hyprctl dispatch dpms on";
  #       ignore_dbus_inhibit = false; # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
  #       ignore_systemd_inhibit = false; # whether to ignore systemd-inhibit --what=idle inhibitors
  #       inhibit_screensaver = true;
  #     };
  #     listener = [
  #       {
  #         # Lock screen on lid close
  #         # timeout = 0;
  #         on-lid = "hyprlock";
  #       }
  #       # {
  #       #   # Lock the screen
  #       #   timeout = 300;
  #       #   on-timeout = "loginctl lock-session";
  #       # }
  #       # {
  #       #   # Turn off screen
  #       #   timeout = 420;
  #       #   on-timeout = "hyprctl dispatch dpms off";
  #       #   on-resume = "hyprctl dispatch dpms on";
  #       # }
  #       # {
  #       #   # Suspend the system
  #       #   timeout = 600;
  #       #   on-timeout = "systemctl suspend";
  #       # }
  #     ];
  #   };
  };
}
