{...}: {
  flake.homeModules.sessionMenuScript = {
    pkgs,
    ...
  }: let
    sessionMenuScript = pkgs.writeShellApplication {
      name = "sessionMenuScript";
      runtimeInputs = with pkgs; [util-linux];
      text = ''
        # rofi script mode: session menu

        run() { setsid -f "$@" >/dev/null 2>&1; }

        header() { printf '\0prompt\x1f%s\n\0no-custom\x1ftrue\n' "$1"; }
        item()   { printf '%s\0icon\x1f%s\x1finfo\x1f%s\n' "$1" "$2" "$3"; }

        main_menu() {
          header "Session"
          item "Lock"      system-lock-screen lock
          item "Suspend"   system-suspend     suspend
          item "Hibernate" system-hibernate   hibernate
          item "Log out"   system-log-out     ask:logout
          item "Reboot"    system-reboot      ask:reboot
          item "Shutdown"  system-shutdown    ask:poweroff
        }

        confirm_menu() {
          header "Really $1?"
          printf 'Yes\0icon\x1f%s\x1finfo\x1f%s\x1furgent\x1ftrue\n' dialog-ok "do:$1"
          item "Cancel" dialog-cancel menu
        }

        case "''${ROFI_INFO:-}" in
          lock)        run loginctl lock-session ;;
          suspend)     run systemctl suspend ;;
          hibernate)   run systemctl hibernate ;;
          ask:*)       confirm_menu "''${ROFI_INFO#ask:}" ;;
          do:logout)   run hyprctl dispatch exit ;;
          do:reboot)   run systemctl reboot ;;
          do:poweroff) run systemctl poweroff ;;
          *)           main_menu ;;
        esac
      '';
    };
  in {
    home.packages = [sessionMenuScript];
  };
}
