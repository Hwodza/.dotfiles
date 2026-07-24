{
  self,
  inputs,
  ...
}: {
  flake.homeModules.hyprlock = {config, ...}: {
    programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          hide_cursor = false;
        };

        animations = {
          enabled = true;
          bezier = "linear, 1, 1, 0, 0";
          animation = [
            "fadeIn, 1, 5, linear"
            "fadeOut, 1, 5, linear"
            "inputFieldDots, 1, 2, linear"
          ];
        };

        background = {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
        };

        input-field = {
          monitor = "";
          size = "20%, 5%";
          outline_thickness = 3;
          # inner_color = "rgba(0, 0, 0, 0.0)";
          # outer_color = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          # check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
          # fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";
          # font_color = "rgb(143, 143, 143)";
          fade_on_empty = false;
          rounding = 15;
          font_family = "Monospace";
          placeholder_text = "Input password...";
          fail_text = "$PAMFAIL$FPRINTFAIL";
          dots_spacing = 0.3;
          position = "0, -20";
          halign = "center";
          valign = "center";
        };

        label = [
          # TIME
          {
            monitor = "";
            text = "$TIME";
            font_size = 90;
            font_family = "Monospace";
            position = "-30, 0";
            halign = "right";
            valign = "top";
          }
          # DATE
          {
            monitor = "";
            text = ''cmd[update:60000] date +"%A, %d %B %Y"'';
            font_size = 25;
            font_family = "Monospace";
            position = "-30, -150";
            halign = "right";
            valign = "top";
          }
          # KEYBOARD LAYOUT
          {
            monitor = "";
            text = "$LAYOUT[en,ru]";
            font_size = 24;
            onclick = "hyprctl switchxkblayout all next";
            position = "250, -20";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
