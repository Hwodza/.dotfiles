{
  self,
  inputs,
  ...
}: let
  base16 = {
    scheme = "Tokyo Night Runtime";
    author = "Henry";
    base00 = "1a1b26";
    base01 = "24283b";
    base02 = "414868";
    base03 = "565f89";
    base04 = "a9b1d6";
    base05 = "c0caf5";
    base06 = "c0caf5";
    base07 = "ffffff";
    base08 = "f7768e";
    base09 = "ff9e64";
    base0A = "e0af68";
    base0B = "9ece6a";
    base0C = "7dcfff";
    base0D = "7aa2f7";
    base0E = "bb9af7";
    base0F = "db4b4b";
  };

  hex = color: "#${color}";
  mkMatugenColor = color: {
    dark.color = color;
    default.color = color;
    light.color = color;
  };
  mkBase16Color = color: mkMatugenColor (hex color);

  matugenDefault = {
    base16 = {
      base00 = mkBase16Color base16.base00;
      base01 = mkBase16Color base16.base01;
      base02 = mkBase16Color base16.base02;
      base03 = mkBase16Color base16.base03;
      base04 = mkBase16Color base16.base04;
      base05 = mkBase16Color base16.base05;
      base06 = mkBase16Color base16.base06;
      base07 = mkBase16Color base16.base07;
      base08 = mkBase16Color base16.base08;
      base09 = mkBase16Color base16.base09;
      base0a = mkBase16Color base16.base0A;
      base0b = mkBase16Color base16.base0B;
      base0c = mkBase16Color base16.base0C;
      base0d = mkBase16Color base16.base0D;
      base0e = mkBase16Color base16.base0E;
      base0f = mkBase16Color base16.base0F;
    };
    colors = {
      background = mkMatugenColor (hex base16.base00);
      error = mkMatugenColor (hex base16.base08);
      error_container = mkMatugenColor (hex base16.base0F);
      inverse_on_surface = mkMatugenColor (hex base16.base01);
      inverse_primary = mkMatugenColor (hex base16.base0D);
      inverse_surface = mkMatugenColor (hex base16.base05);
      on_background = mkMatugenColor (hex base16.base05);
      on_error = mkMatugenColor (hex base16.base00);
      on_error_container = mkMatugenColor (hex base16.base05);
      on_primary = mkMatugenColor (hex base16.base00);
      on_primary_container = mkMatugenColor (hex base16.base05);
      on_secondary = mkMatugenColor (hex base16.base00);
      on_secondary_container = mkMatugenColor (hex base16.base05);
      on_surface = mkMatugenColor (hex base16.base05);
      on_surface_variant = mkMatugenColor (hex base16.base04);
      on_tertiary = mkMatugenColor (hex base16.base00);
      on_tertiary_container = mkMatugenColor (hex base16.base05);
      outline = mkMatugenColor (hex base16.base03);
      outline_variant = mkMatugenColor (hex base16.base02);
      primary = mkMatugenColor (hex base16.base0D);
      primary_container = mkMatugenColor (hex base16.base02);
      scrim = mkMatugenColor "#000000";
      secondary = mkMatugenColor (hex base16.base0C);
      secondary_container = mkMatugenColor (hex base16.base02);
      shadow = mkMatugenColor "#000000";
      source_color = mkMatugenColor (hex base16.base0D);
      surface = mkMatugenColor (hex base16.base00);
      surface_bright = mkMatugenColor (hex base16.base02);
      surface_container = mkMatugenColor (hex base16.base01);
      surface_container_high = mkMatugenColor (hex base16.base02);
      surface_container_highest = mkMatugenColor (hex base16.base03);
      surface_container_low = mkMatugenColor (hex base16.base00);
      surface_container_lowest = mkMatugenColor "#11111b";
      surface_dim = mkMatugenColor (hex base16.base00);
      surface_tint = mkMatugenColor (hex base16.base0D);
      surface_variant = mkMatugenColor (hex base16.base02);
      tertiary = mkMatugenColor (hex base16.base0E);
      tertiary_container = mkMatugenColor (hex base16.base02);
    };
    image = null;
    is_dark_mode = true;
    mode = "dark";
  };

  noctaliaColors = {
    mError = matugenDefault.colors.error.default.color;
    mOnError = matugenDefault.colors.on_error.default.color;
    mOnPrimary = matugenDefault.colors.on_primary.default.color;
    mOnSecondary = matugenDefault.colors.on_secondary.default.color;
    mOnSurface = matugenDefault.colors.on_surface.default.color;
    mOnSurfaceVariant = matugenDefault.colors.on_surface_variant.default.color;
    mOnTertiary = matugenDefault.colors.on_tertiary.default.color;
    mOutline = matugenDefault.colors.outline.default.color;
    mPrimary = matugenDefault.colors.primary.default.color;
    mSecondary = matugenDefault.colors.secondary.default.color;
    mShadow = matugenDefault.colors.shadow.default.color;
    mSurface = matugenDefault.colors.surface.default.color;
    mSurfaceVariant = matugenDefault.colors.surface_variant.default.color;
    mTertiary = matugenDefault.colors.tertiary.default.color;
  };
in {
  flake.theme = {
    inherit base16 matugenDefault noctaliaColors;
  };

  flake.nixosModules.theme = {pkgs, ...}: {
    imports = [
      inputs.stylix.nixosModules.stylix
    ];

    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = base16;

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.ubuntu-sans;
          name = "Ubuntu Sans";
        };
        serif = {
          package = pkgs.ubuntu-sans;
          name = "Ubuntu Sans";
        };
        sizes = {
          applications = 11;
          desktop = 11;
          popups = 11;
          terminal = 15;
        };
      };
    };
  };

  flake.homeModules.theme = {
    config,
    lib,
    pkgs,
    ...
  }: let
    runtimeDir = "${config.home.homeDirectory}/.local/state/theme/current";
    matugenConfig = "${config.home.homeDirectory}/.config/matugen/config.toml";
    defaultPalette = pkgs.writeText "default-theme-colors.json" (builtins.toJSON self.theme.matugenDefault);

    themeApply = pkgs.writeShellApplication {
      name = "theme-apply";
      runtimeInputs = with pkgs; [
        coreutils
        jq
        kitty
        tmux
        hyprland
      ];
      text = ''
                set -euo pipefail

                render_only=0
                if [ "''${1:-}" = "--render-only" ]; then
                  render_only=1
                fi

                current_dir="''${HOME}/.local/state/theme/current"
                palette="''${current_dir}/colors.json"
                noctalia_colors="''${current_dir}/noctalia-colors.json"

                if [ ! -f "$palette" ]; then
                  echo "theme-apply: missing palette: $palette" >&2
                  exit 1
                fi

                mkdir -p "$current_dir"

                get_color() {
                  local query="$1"
                  local fallback="$2"
                  local value
                  value="$(jq -r "$query // empty" "$palette")"
                  if [ -n "$value" ] && [ "$value" != "null" ]; then
                    printf '%s' "$value"
                  else
                    printf '%s' "$fallback"
                  fi
                }

                strip_hash() {
                  printf '%s' "''${1#\#}"
                }

                base00="$(get_color '.base16.base00.default.color' '#1a1b26')"
                base01="$(get_color '.base16.base01.default.color' '#24283b')"
                base02="$(get_color '.base16.base02.default.color' '#414868')"
                base03="$(get_color '.base16.base03.default.color' '#565f89')"
                base04="$(get_color '.base16.base04.default.color' '#a9b1d6')"
                base05="$(get_color '.base16.base05.default.color' '#c0caf5')"
                base07="$(get_color '.base16.base07.default.color' '#ffffff')"
                base08="$(get_color '.base16.base08.default.color' '#f7768e')"
                base09="$(get_color '.base16.base09.default.color' '#ff9e64')"
                base0a="$(get_color '.base16.base0a.default.color' '#e0af68')"
                base0b="$(get_color '.base16.base0b.default.color' '#9ece6a')"
                base0c="$(get_color '.base16.base0c.default.color' '#7dcfff')"
                base0d="$(get_color '.base16.base0d.default.color' '#7aa2f7')"
                base0e="$(get_color '.base16.base0e.default.color' '#bb9af7')"

                primary="$(get_color '.colors.primary.default.color' "$base0d")"
                on_primary="$(get_color '.colors.on_primary.default.color' "$base00")"
                secondary="$(get_color '.colors.secondary.default.color' "$base0c")"
                on_secondary="$(get_color '.colors.on_secondary.default.color' "$base00")"
                tertiary="$(get_color '.colors.tertiary.default.color' "$base0e")"
                on_tertiary="$(get_color '.colors.on_tertiary.default.color' "$base00")"
                surface="$(get_color '.colors.surface.default.color' "$base00")"
                surface_variant="$(get_color '.colors.surface_variant.default.color' "$base02")"
                on_surface="$(get_color '.colors.on_surface.default.color' "$base05")"
                on_surface_variant="$(get_color '.colors.on_surface_variant.default.color' "$base04")"
                outline="$(get_color '.colors.outline.default.color' "$base03")"
                error="$(get_color '.colors.error.default.color' "$base08")"
                on_error="$(get_color '.colors.on_error.default.color' "$base00")"
                shadow="$(get_color '.colors.shadow.default.color' '#000000')"

                cat > "''${current_dir}/kitty.conf" <<EOF
        foreground $base05
        background $base00
        selection_foreground $base00
        selection_background $base03
        cursor $base05
        cursor_text_color $base00
        active_tab_foreground $base00
        active_tab_background $primary
        inactive_tab_foreground $base04
        inactive_tab_background $base01
        color0 $base00
        color1 $base08
        color2 $base0b
        color3 $base0a
        color4 $base0d
        color5 $base0e
        color6 $base0c
        color7 $base05
        color8 $base03
        color9 $base08
        color10 $base0b
        color11 $base0a
        color12 $base0d
        color13 $base0e
        color14 $base0c
        color15 $base07
        EOF

                cat > "''${current_dir}/rofi.rasi" <<EOF
        * {
            b-color: ''${base00}FF;
            fg-color: ''${base05}FF;
            fgp-color: ''${base04}FF;
            hl-color: ''${primary}FF;
            hlt-color: ''${on_primary}FF;
            alt-color: ''${base01}FF;
            wbg-color: ''${base00}CC;
            w-border-color: ''${primary}FF;
        }
        EOF

                cat > "''${current_dir}/hyprland.lua" <<EOF
        return {
          active_border = "rgba($(strip_hash "$primary")ff)",
          inactive_border = "rgba($(strip_hash "$outline")aa)",
          shadow = "rgba($(strip_hash "$shadow")ee)",
        }
        EOF

                cat > "''${current_dir}/tmux.conf" <<EOF
        set -g status-style "bg=$base00,fg=$base05"
        set -g message-style "bg=$base02,fg=$base07"
        set -g message-command-style "bg=$base02,fg=$base07"
        set -g mode-style "bg=$primary,fg=$on_primary"
        set -g pane-border-style "fg=$base02"
        set -g pane-active-border-style "fg=$primary"
        set -g window-status-style "bg=$base00,fg=$base04"
        set -g window-status-current-style "bg=$primary,fg=$on_primary,bold"
        set -g window-status-activity-style "bg=$base00,fg=$base0a"
        set -g status-left "#[fg=$on_primary,bg=$primary,bold] #S #[fg=$primary,bg=$base00,nobold]"
        set -g status-right "#[fg=$base04,bg=$base00] %H:%M #[fg=$on_primary,bg=$primary,bold] %d %b "
        EOF

                cat > "''${current_dir}/neovim.lua" <<EOF
        vim.g.colors_name = "matugen-runtime"
        vim.o.termguicolors = true

        local function hi(group, opts)
          vim.api.nvim_set_hl(0, group, opts)
        end

        hi("Normal", { fg = "$base05", bg = "$base00" })
        hi("NormalNC", { fg = "$base05", bg = "$base00" })
        hi("NormalFloat", { fg = "$base05", bg = "$base01" })
        hi("FloatBorder", { fg = "$primary", bg = "$base01" })
        hi("Cursor", { fg = "$base00", bg = "$base05" })
        hi("CursorLine", { bg = "$base01" })
        hi("LineNr", { fg = "$base03" })
        hi("CursorLineNr", { fg = "$primary", bold = true })
        hi("SignColumn", { fg = "$base04", bg = "$base00" })
        hi("StatusLine", { fg = "$base05", bg = "$base02" })
        hi("StatusLineNC", { fg = "$base04", bg = "$base01" })
        hi("WinSeparator", { fg = "$base02" })
        hi("Visual", { bg = "$base02" })
        hi("Search", { fg = "$base00", bg = "$base0a" })
        hi("IncSearch", { fg = "$base00", bg = "$primary" })
        hi("Pmenu", { fg = "$base05", bg = "$base01" })
        hi("PmenuSel", { fg = "$on_primary", bg = "$primary" })
        hi("MatchParen", { fg = "$primary", bold = true })
        hi("Comment", { fg = "$base03", italic = true })
        hi("Constant", { fg = "$base09" })
        hi("String", { fg = "$base0b" })
        hi("Identifier", { fg = "$base0d" })
        hi("Function", { fg = "$base0d", bold = true })
        hi("Statement", { fg = "$base0e" })
        hi("Keyword", { fg = "$base0e" })
        hi("PreProc", { fg = "$base0c" })
        hi("Type", { fg = "$base0a" })
        hi("Special", { fg = "$base0c" })
        hi("Underlined", { fg = "$primary", underline = true })
        hi("Error", { fg = "$error" })
        hi("Todo", { fg = "$base0a", bold = true })
        hi("DiagnosticError", { fg = "$base08" })
        hi("DiagnosticWarn", { fg = "$base0a" })
        hi("DiagnosticInfo", { fg = "$base0c" })
        hi("DiagnosticHint", { fg = "$base0b" })
        hi("DiffAdd", { fg = "$base0b", bg = "$base01" })
        hi("DiffChange", { fg = "$base0a", bg = "$base01" })
        hi("DiffDelete", { fg = "$base08", bg = "$base01" })
        hi("TelescopeBorder", { fg = "$primary", bg = "$base01" })
        hi("TelescopeNormal", { fg = "$base05", bg = "$base01" })
        hi("TelescopeSelection", { fg = "$base07", bg = "$base02" })
        EOF

                cat > "$noctalia_colors" <<EOF
        {
          "mError": "$error",
          "mOnError": "$on_error",
          "mOnPrimary": "$on_primary",
          "mOnSecondary": "$on_secondary",
          "mOnSurface": "$on_surface",
          "mOnSurfaceVariant": "$on_surface_variant",
          "mOnTertiary": "$on_tertiary",
          "mOutline": "$outline",
          "mPrimary": "$primary",
          "mSecondary": "$secondary",
          "mShadow": "$shadow",
          "mSurface": "$surface",
          "mSurfaceVariant": "$surface_variant",
          "mTertiary": "$tertiary"
        }
        EOF

                mkdir -p "''${HOME}/.config/noctalia"
                cp "$noctalia_colors" "''${HOME}/.config/noctalia/colors.json"

                if [ "$render_only" -eq 1 ]; then
                  exit 0
                fi

                if command -v hyprctl >/dev/null 2>&1; then
                  hyprctl reload >/dev/null 2>&1 || true
                fi

                if command -v kitty >/dev/null 2>&1; then
                  kitty @ set-colors --all "''${current_dir}/kitty.conf" >/dev/null 2>&1 || true
                fi

                if command -v tmux >/dev/null 2>&1 && tmux has-session >/dev/null 2>&1; then
                  tmux source-file "''${current_dir}/tmux.conf" >/dev/null 2>&1 || true
                fi
      '';
    };

    setWallpaper = pkgs.writeShellApplication {
      name = "set-wallpaper";
      runtimeInputs = with pkgs; [
        awww
        coreutils
        jq
        matugen
        systemd
        themeApply
      ];
      text = ''
        set -euo pipefail

        if [ "$#" -ne 1 ]; then
          echo "usage: set-wallpaper /path/to/image" >&2
          exit 2
        fi

        image="$1"
        if [ ! -f "$image" ]; then
          echo "set-wallpaper: not a file: $image" >&2
          exit 1
        fi

        current_dir="''${HOME}/.local/state/theme/current"
        mkdir -p "$current_dir"

        systemctl --user start awww.service >/dev/null 2>&1 || true
        awww img --resize crop --transition-type fade --transition-duration 1.2 --transition-fps 60 "$image"

        tmp="''${current_dir}/colors.json.tmp"
        matugen image "$image" --mode dark --config ${lib.escapeShellArg matugenConfig} --json hex --quiet > "$tmp"
        jq empty "$tmp"
        mv "$tmp" "''${current_dir}/colors.json"

        theme-apply
      '';
    };

    themeReset = pkgs.writeShellApplication {
      name = "theme-reset";
      runtimeInputs = with pkgs; [
        coreutils
        themeApply
      ];
      text = ''
        set -euo pipefail

        default_palette="''${HOME}/.config/theme/default/colors.json"
        fallback_palette=${lib.escapeShellArg defaultPalette}
        current_dir="''${HOME}/.local/state/theme/current"

        if [ ! -f "$default_palette" ]; then
          default_palette="$fallback_palette"
        fi

        mkdir -p "$current_dir"
        cp "$default_palette" "''${current_dir}/colors.json"
        theme-apply
      '';
    };
  in {
    stylix.targets = {
      hyprland.enable = lib.mkForce false;
      neovim.enable = lib.mkForce false;
      rofi.enable = lib.mkForce false;
      tmux.enable = lib.mkForce false;
    };

    home.packages = [
      pkgs.awww
      pkgs.matugen
      setWallpaper
      themeApply
      themeReset
    ];

    home.file.".config/theme/default/colors.json".text = builtins.toJSON self.theme.matugenDefault;
    home.file.".config/matugen/config.toml".text = ''
      [config]
      version_check = false
      fallback_color = "${self.theme.matugenDefault.colors.source_color.default.color}"
      caching = false

      [templates]
    '';

    gtk.gtk2.force = true;
    xdg.configFile = {
      "gtk-3.0/settings.ini".force = true;
      "gtk-4.0/settings.ini".force = true;
    };

    systemd.user.services.awww = {
      Unit = {
        Description = "Wayland wallpaper daemon";
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${lib.getExe' pkgs.awww "awww-daemon"} --quiet";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    home.activation.dynamicTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      runtime_dir=${lib.escapeShellArg runtimeDir}
      default_palette="${config.home.homeDirectory}/.config/theme/default/colors.json"
      fallback_palette=${lib.escapeShellArg defaultPalette}

      mkdir -p "$runtime_dir"
      if [ ! -f "$runtime_dir/colors.json" ]; then
        if [ -f "$default_palette" ]; then
          cp "$default_palette" "$runtime_dir/colors.json"
        else
          cp "$fallback_palette" "$runtime_dir/colors.json"
        fi
      fi

      ${lib.getExe themeApply} --render-only
    '';
  };
}
