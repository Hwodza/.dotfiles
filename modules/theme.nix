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

  # Simplified: plain hex values, no dark/light nesting
  matugenDefault = {
    base16 = {
      base00 = hex base16.base00;
      base01 = hex base16.base01;
      base02 = hex base16.base02;
      base03 = hex base16.base03;
      base04 = hex base16.base04;
      base05 = hex base16.base05;
      base06 = hex base16.base06;
      base07 = hex base16.base07;
      base08 = hex base16.base08;
      base09 = hex base16.base09;
      base0a = hex base16.base0A;
      base0b = hex base16.base0B;
      base0c = hex base16.base0C;
      base0d = hex base16.base0D;
      base0e = hex base16.base0E;
      base0f = hex base16.base0F;
    };
    colors = {
      background = hex base16.base00;
      error = hex base16.base08;
      error_container = hex base16.base0F;
      inverse_on_surface = hex base16.base01;
      inverse_primary = hex base16.base0D;
      inverse_surface = hex base16.base05;
      on_background = hex base16.base05;
      on_error = hex base16.base00;
      on_error_container = hex base16.base05;
      on_primary = hex base16.base00;
      on_primary_container = hex base16.base05;
      on_secondary = hex base16.base00;
      on_secondary_container = hex base16.base05;
      on_surface = hex base16.base05;
      on_surface_variant = hex base16.base04;
      on_tertiary = hex base16.base00;
      on_tertiary_container = hex base16.base05;
      outline = hex base16.base03;
      outline_variant = hex base16.base02;
      primary = hex base16.base0D;
      primary_container = hex base16.base02;
      scrim = "#000000";
      secondary = hex base16.base0C;
      secondary_container = hex base16.base02;
      shadow = "#000000";
      source_color = hex base16.base0D;
      surface = hex base16.base00;
      surface_bright = hex base16.base02;
      surface_container = hex base16.base01;
      surface_container_high = hex base16.base02;
      surface_container_highest = hex base16.base03;
      surface_container_low = hex base16.base00;
      surface_container_lowest = "#11111b";
      surface_dim = hex base16.base00;
      surface_tint = hex base16.base0D;
      surface_variant = hex base16.base02;
      tertiary = hex base16.base0E;
      tertiary_container = hex base16.base02;
    };
    image = null;
    is_dark_mode = true;
    mode = "dark";
  };

  noctaliaColors = {
    mError = matugenDefault.colors.error;
    mOnError = matugenDefault.colors.on_error;
    mOnPrimary = matugenDefault.colors.on_primary;
    mOnSecondary = matugenDefault.colors.on_secondary;
    mOnSurface = matugenDefault.colors.on_surface;
    mOnSurfaceVariant = matugenDefault.colors.on_surface_variant;
    mOnTertiary = matugenDefault.colors.on_tertiary;
    mOutline = matugenDefault.colors.outline;
    mPrimary = matugenDefault.colors.primary;
    mSecondary = matugenDefault.colors.secondary;
    mShadow = matugenDefault.colors.shadow;
    mSurface = matugenDefault.colors.surface;
    mSurfaceVariant = matugenDefault.colors.surface_variant;
    mTertiary = matugenDefault.colors.tertiary;
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
    matugenTemplates = "${config.home.homeDirectory}/.config/matugen/templates";

    setWallpaper = pkgs.writeShellApplication {
      name = "set-wallpaper";
      runtimeInputs = with pkgs; [
        awww
        kitty
        matugen
        systemd
      ];
      text = ''
        set -euo pipefail

        if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
          echo "usage: set-wallpaper /path/to/image [source-color-index]" >&2
          exit 2
        fi

        image="$1"
        if [ ! -f "$image" ]; then
          echo "set-wallpaper: not a file: $image" >&2
          exit 1
        fi

        source_color_index="''${2:-0}"

        systemctl --user start awww.service >/dev/null 2>&1 || true
        awww img --resize crop --transition-type fade --transition-duration 1.2 --transition-fps 60 "$image"

        matugen image "$image" --mode dark --source-color-index "$source_color_index" --config ${lib.escapeShellArg matugenConfig}
      '';
    };

    themeReset = pkgs.writeShellApplication {
      name = "theme-reset";
      runtimeInputs = with pkgs; [
        matugen
      ];
      text = ''
        set -euo pipefail
        matugen color ${matugenDefault.colors.source_color} --mode dark --config ${lib.escapeShellArg matugenConfig} --json hex --quiet
      '';
    };

    # Template files that matugen renders with interpolation
    tuxedoTemplate = pkgs.writeText "customTuxedo.toml" ''
      name = CustomWallpaperScheme
      bg = {{ colors.background.default.hex }}
      panel = {{ colors.surface_container_low.default.hex }}
      border = {{ colors.outline_variant.default.hex }}
      fg = {{ colors.on_background.default.hex }}
      dim = {{ colors.on_surface_variant.default.hex }}
      accent = {{ colors.primary.default.hex }}
      cursor = {{ colors.secondary_container.default.hex }}
      selection = {{ colors.secondary_container.default.hex }}
      selected = {{ colors.secondary_container.default.hex }}
      statusbar = {{ colors.surface_container.default.hex }}
      status_fg = {{ colors.on_surface_variant.default.hex }}
      mode_fg = {{ colors.on_primary.default.hex }}
      mode_bg = {{ colors.primary.default.hex }}
      pri_a = {{ colors.error.default.hex }}
      pri_b = {{ colors.tertiary.default.hex }}
      pri_c = {{ colors.secondary.default.hex }}
      pri_d = {{ colors.primary.default.hex }}
      pri_other = {{ colors.primary_container.default.hex }}
      project = {{ colors.primary.default.hex }}
      context = {{ colors.tertiary_container.default.hex }}
      done = {{ colors.outline.default.hex }}
      matched = {{ colors.inverse_primary.default.hex }}
      due = {{ colors.inverse_primary.default.hex }}
      overdue = {{ colors.error.default.hex }}
      today = {{ colors.error.default.hex }}
    '';

    kittyTemplate = pkgs.writeText "kitty.conf" ''
      foreground {{colors.on_surface.default.hex}}
      background {{colors.surface.default.hex}}
      selection_foreground {{colors.surface.default.hex}}
      selection_background {{colors.outline.default.hex}}
      cursor {{colors.on_surface.default.hex}}
      cursor_text_color {{colors.surface.default.hex}}
      active_tab_foreground {{colors.surface.default.hex}}
      active_tab_background {{colors.primary.default.hex}}
      inactive_tab_foreground {{colors.on_surface_variant.default.hex}}
      inactive_tab_background {{colors.surface_container.default.hex}}
      color0 {{colors.surface.default.hex}}
      color1 {{colors.error.default.hex}}
      color2 {{colors.secondary.default.hex}}
      color3 {{colors.tertiary.default.hex}}
      color4 {{colors.primary.default.hex}}
      color5 {{colors.tertiary.default.hex}}
      color6 {{colors.secondary.default.hex}}
      color7 {{colors.on_surface.default.hex}}
      color8 {{colors.outline.default.hex}}
      color9 {{colors.error.default.hex}}
      color10 {{colors.secondary.default.hex}}
      color11 {{colors.tertiary.default.hex}}
      color12 {{colors.primary.default.hex}}
      color13 {{colors.tertiary.default.hex}}
      color14 {{colors.secondary.default.hex}}
      color15 {{colors.on_background.default.hex}}
    '';

    rofiTemplate = pkgs.writeText "rofi.rasi" ''
      * {
          b-color: {{colors.surface.default.hex}}FF;
          fg-color: {{colors.on_surface.default.hex}}FF;
          fgp-color: {{colors.on_surface_variant.default.hex}}FF;
          hl-color: {{colors.primary.default.hex}}FF;
          hlt-color: {{colors.on_primary.default.hex}}FF;
          alt-color: {{colors.surface_container.default.hex}}FF;
          wbg-color: {{colors.surface.default.hex}}CC;
          w-border-color: {{colors.primary.default.hex}}FF;
      }
    '';

    tmuxTemplate = pkgs.writeText "tmux.conf" ''
      set -g status-style "bg={{colors.surface.default.hex}},fg={{colors.on_surface.default.hex}}"
      set -g message-style "bg={{colors.surface_container_high.default.hex}},fg={{colors.on_background.default.hex}}"
      set -g message-command-style "bg={{colors.surface_container_high.default.hex}},fg={{colors.on_background.default.hex}}"
      set -g mode-style "bg={{colors.primary.default.hex}},fg={{colors.on_primary.default.hex}}"
      set -g pane-border-style "fg={{colors.surface_container_high.default.hex}}"
      set -g pane-active-border-style "fg={{colors.primary.default.hex}}"
      set -g window-status-style "bg={{colors.surface.default.hex}},fg={{colors.on_surface_variant.default.hex}}"
      set -g window-status-current-style "bg={{colors.primary.default.hex}},fg={{colors.on_primary.default.hex}},bold"
      set -g window-status-activity-style "bg={{colors.surface.default.hex}},fg={{colors.tertiary.default.hex}}"
      set -g status-left "#[fg={{colors.on_primary.default.hex}},bg={{colors.primary.default.hex}},bold] #S #[fg={{colors.primary.default.hex}},bg={{colors.surface.default.hex}},nobold]"
      set -g status-right "#[fg={{colors.on_surface_variant.default.hex}},bg={{colors.surface.default.hex}}] %H:%M #[fg={{colors.on_primary.default.hex}},bg={{colors.primary.default.hex}},bold] %d %b "
    '';

    hyprlandTemplate = pkgs.writeText "hyprland.lua" ''
      return {
        active_border = "rgba({{colors.primary.default.hex_stripped}}ff)",
        inactive_border = "rgba({{colors.outline.default.hex_stripped}}aa)",
        shadow = "rgba({{colors.shadow.default.hex_stripped}}ee)",
      }
    '';

    neovimTemplate = pkgs.writeText "neovim.lua" ''
      vim.g.colors_name = "matugen-runtime"
      vim.o.termguicolors = true

      local function hi(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
      end

      hi("Normal",            { fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface.default.hex}}" })
      hi("NormalNC",          { fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface.default.hex}}" })
      hi("NormalFloat",       { fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface_container.default.hex}}" })
      hi("FloatBorder",       { fg = "{{colors.primary.default.hex}}",     bg = "{{colors.surface_container.default.hex}}" })
      hi("Cursor",            { fg = "{{colors.surface.default.hex}}",    bg = "{{colors.on_surface.default.hex}}" })
      hi("CursorLine",        { bg = "{{colors.surface_container.default.hex}}" })
      hi("LineNr",            { fg = "{{colors.outline.default.hex}}" })
      hi("CursorLineNr",      { fg = "{{colors.primary.default.hex}}", bold = true })
      hi("SignColumn",        { fg = "{{colors.on_surface_variant.default.hex}}", bg = "{{colors.surface.default.hex}}" })
      hi("StatusLine",        { fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface_container_high.default.hex}}" })
      hi("StatusLineNC",      { fg = "{{colors.on_surface_variant.default.hex}}", bg = "{{colors.surface_container.default.hex}}" })
      hi("WinSeparator",      { fg = "{{colors.surface_container_high.default.hex}}" })
      hi("Visual",            { bg = "{{colors.surface_container_high.default.hex}}" })
      hi("Search",            { fg = "{{colors.surface.default.hex}}", bg = "{{colors.tertiary.default.hex}}" })
      hi("IncSearch",         { fg = "{{colors.surface.default.hex}}", bg = "{{colors.primary.default.hex}}" })
      hi("Pmenu",             { fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface_container.default.hex}}" })
      hi("PmenuSel",          { fg = "{{colors.on_primary.default.hex}}", bg = "{{colors.primary.default.hex}}" })
      hi("MatchParen",        { fg = "{{colors.primary.default.hex}}", bold = true })
      hi("Comment",           { fg = "{{colors.outline.default.hex}}", italic = true })
      hi("Constant",          { fg = "{{colors.tertiary.default.hex}}" })
      hi("String",            { fg = "{{colors.secondary.default.hex}}" })
      hi("Identifier",        { fg = "{{colors.primary.default.hex}}" })
      hi("Function",          { fg = "{{colors.primary.default.hex}}", bold = true })
      hi("Statement",         { fg = "{{colors.tertiary.default.hex}}" })
      hi("Keyword",           { fg = "{{colors.tertiary.default.hex}}" })
      hi("PreProc",           { fg = "{{colors.secondary.default.hex}}" })
      hi("Type",              { fg = "{{colors.tertiary.default.hex}}" })
      hi("Special",           { fg = "{{colors.secondary.default.hex}}" })
      hi("Underlined",        { fg = "{{colors.primary.default.hex}}", underline = true })
      hi("Error",             { fg = "{{colors.error.default.hex}}" })
      hi("Todo",              { fg = "{{colors.tertiary.default.hex}}", bold = true })
      hi("DiagnosticError",   { fg = "{{colors.error.default.hex}}" })
      hi("DiagnosticWarn",    { fg = "{{colors.tertiary.default.hex}}" })
      hi("DiagnosticInfo",    { fg = "{{colors.secondary.default.hex}}" })
      hi("DiagnosticHint",    { fg = "{{colors.secondary.default.hex}}" })
      hi("DiffAdd",           { fg = "{{colors.secondary.default.hex}}", bg = "{{colors.surface_container.default.hex}}" })
      hi("DiffChange",        { fg = "{{colors.tertiary.default.hex}}", bg = "{{colors.surface_container.default.hex}}" })
      hi("DiffDelete",        { fg = "{{colors.error.default.hex}}", bg = "{{colors.surface_container.default.hex}}" })
      hi("TelescopeBorder",   { fg = "{{colors.primary.default.hex}}", bg = "{{colors.surface_container.default.hex}}" })
      hi("TelescopeNormal",   { fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface_container.default.hex}}" })
      hi("TelescopeSelection",{ fg = "{{colors.on_background.default.hex}}", bg = "{{colors.surface_container_high.default.hex}}" })
    '';

    noctaliaTemplate = pkgs.writeText "noctalia-colors.json" ''
      {
        "mError": "{{colors.error.default.hex}}",
        "mOnError": "{{colors.on_error.default.hex}}",
        "mOnPrimary": "{{colors.on_primary.default.hex}}",
        "mOnSecondary": "{{colors.on_secondary.default.hex}}",
        "mOnSurface": "{{colors.on_surface.default.hex}}",
        "mOnSurfaceVariant": "{{colors.on_surface_variant.default.hex}}",
        "mOnTertiary": "{{colors.on_tertiary.default.hex}}",
        "mOutline": "{{colors.outline.default.hex}}",
        "mPrimary": "{{colors.primary.default.hex}}",
        "mSecondary": "{{colors.secondary.default.hex}}",
        "mShadow": "{{colors.shadow.default.hex}}",
        "mSurface": "{{colors.surface.default.hex}}",
        "mSurfaceVariant": "{{colors.surface_variant.default.hex}}",
        "mTertiary": "{{colors.tertiary.default.hex}}"
      }
    '';

    # lazygit config: complete YAML file (lazygit does not support include/source).
    # Non-theme settings (keybindings, customCommands, etc.) must be added here
    # alongside the matugen interpolation in gui.theme.
    lazygitTemplate = pkgs.writeText "lazygit.yml" ''
      gui:
        theme:
          activeBorderColor:
            - '{{ colors.primary.default.hex }}'
            - bold
          inactiveBorderColor:
            - '{{ colors.outline.default.hex }}'
          searchingActiveBorderColor:
            - '{{ colors.tertiary.default.hex }}'
            - bold
          optionsTextColor:
            - '{{ colors.secondary.default.hex }}'
          selectedLineBgColor:
            - '{{ colors.primary_container.default.hex }}'
          inactiveViewSelectedLineBgColor:
            - '{{ colors.surface_container_high.default.hex }}'
          cherryPickedCommitFgColor:
            - '{{ colors.on_tertiary_container.default.hex }}'
          cherryPickedCommitBgColor:
            - '{{ colors.tertiary_container.default.hex }}'
          markedBaseCommitFgColor:
            - '{{ colors.on_secondary_container.default.hex }}'
          markedBaseCommitBgColor:
            - '{{ colors.secondary_container.default.hex }}'
          unstagedChangesColor:
            - '{{ colors.error.default.hex }}'
          defaultFgColor:
            - '{{ colors.on_background.default.hex }}'

      git:
        paging:
          colorArg: always
    '';
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
      themeReset
    ];

    home.file.".config/theme/default/colors.json".text = builtins.toJSON matugenDefault;

    # Matugen config: templates + post_hooks replace theme-apply entirely
    home.file.".config/matugen/config.toml".text = ''
      [config]
      version_check = false
      fallback_color = "${matugenDefault.colors.source_color}"
      caching = false

      [templates.tuxedo]
      input_path = "${matugenTemplates}/customTuxedo.toml"
      output_path = "~/.config/tuxedo/themes/customTuxedo.toml"

      [templates.kitty]
      input_path = "${matugenTemplates}/kitty.conf"
      output_path = "${runtimeDir}/kitty.conf"
      post_hook = "kitty @ set-colors --all ${runtimeDir}/kitty.conf"

      [templates.rofi]
      input_path = "${matugenTemplates}/rofi.rasi"
      output_path = "${runtimeDir}/rofi.rasi"

      [templates.tmux]
      input_path = "${matugenTemplates}/tmux.conf"
      output_path = "${runtimeDir}/tmux.conf"
      post_hook = "tmux source-file ${runtimeDir}/tmux.conf"

      [templates.hyprland]
      input_path = "${matugenTemplates}/hyprland.lua"
      output_path = "${runtimeDir}/hyprland.lua"
      post_hook = "hyprctl reload"

      [templates.neovim]
      input_path = "${matugenTemplates}/neovim.lua"
      output_path = "${runtimeDir}/neovim.lua"

      [templates.lazygit]
      input_path = "${matugenTemplates}/lazygit.yml"
      output_path = "~/.config/lazygit/config.yml"

      [templates.noctalia]
      input_path = "${matugenTemplates}/noctalia-colors.json"
      output_path = "~/.config/noctalia/colors.json"
    '';

    # Write template files
    home.file.".config/matugen/templates/customTuxedo.toml".source = tuxedoTemplate;
    home.file.".config/matugen/templates/kitty.conf".source = kittyTemplate;
    home.file.".config/matugen/templates/rofi.rasi".source = rofiTemplate;
    home.file.".config/matugen/templates/tmux.conf".source = tmuxTemplate;
    home.file.".config/matugen/templates/hyprland.lua".source = hyprlandTemplate;
    home.file.".config/matugen/templates/neovim.lua".source = neovimTemplate;
    home.file.".config/matugen/templates/lazygit.yml".source = lazygitTemplate;
    home.file.".config/matugen/templates/noctalia-colors.json".source = noctaliaTemplate;

    # Noctia colors: let Matugen template create at runtime (Nix writes are read-only)

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

      mkdir -p "$runtime_dir"
      mkdir -p "${config.home.homeDirectory}/.config/noctalia"
      if [ ! -f "$runtime_dir/colors.json" ]; then
        if [ -f "$default_palette" ]; then
          cp "$default_palette" "$runtime_dir/colors.json"
        fi
      fi
    '';
  };
}
