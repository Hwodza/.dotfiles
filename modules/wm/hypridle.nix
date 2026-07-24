{
  self,
  inputs,
  ...
}: {
  # Home-manager module for hypridle
  flake.homeModules.hypridle = {config, ...}: let
    isLaptop = ''
      { [ "$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)" = "9" ] || \
        [ "$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)" = "10" ] || \
        [ "$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)" = "31" ] || \
        [ "$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)" = "32" ]; }
    '';

    isDesktop = ''! ${isLaptop}'';

    onAC = ''[ "$(cat /sys/class/power_supply/AC/online 2>/dev/null)" = "1" ]'';
    onBattery = ''[ "$(cat /sys/class/power_supply/AC/online 2>/dev/null)" = "0" ]'';
  in {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
          inhibit_sleep = 2;
        };

        listener = [
          # --- Shared: lock after 5 minutes ---
          {
            timeout = 300;
            on-timeout = "hyprlock";
          }

          # --- Shared: screen off after 5.5 minutes ---
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }

          # --- Laptop: suspend after 30 min on AC ---
          {
            timeout = 1800;
            on-timeout = "${isLaptop} && ${onAC} && systemctl suspend";
          }

          # --- Laptop: suspend after 7.5 min on battery ---
          {
            timeout = 450;
            on-timeout = "${isLaptop} && ${onBattery} && systemctl suspend";
          }

          # --- Laptop: hibernate after 2 hours regardless of power ---
          {
            timeout = 7200;
            on-timeout = "${isLaptop} && systemctl hibernate";
          }

          # --- Desktop: suspend after 30 min ---
          {
            timeout = 1800;
            on-timeout = "${isDesktop} && systemctl suspend";
          }

          # --- Desktop: hibernate after 24 hours ---
          {
            timeout = 86400;
            on-timeout = "${isDesktop} && systemctl hibernate";
          }
        ];
      };
    };
  };
}
