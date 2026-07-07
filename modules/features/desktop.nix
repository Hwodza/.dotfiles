{self, ...}: {
  flake.homeModules.desktop = {pkgs, ...}: {
    home.packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.kio-extras
      tor-browser
      obsidian
      zathura
      poppler
      obs-studio
      discord
      spotify
      stirling-pdf-desktop
      thunderbird
      pomodoro-gtk
      simple-mtpfs
    ];

    services.udiskie = {
      enable = true;
      automount = true;
      tray = "auto";
    };
  };

  flake.nixosModules.desktop = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.theme
      self.nixosModules.cloudAI
    ];

    # imports = [
    #   self.nixosModules.hypr
    #   {
    #     my.hyprland.package = self.packages.${pkgs.system}.myHyprland;
    #   }
    # ];

    home-manager.users.${config.preferences.user.name}.imports = [
      self.homeModules.desktop
      self.homeModules.theme
      self.homeModules.kitty
      self.homeModules.hypr
    ];
    environment.sessionVariables = {
      TERMINAL = lib.getExe pkgs.kitty;
      EDITOR = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.neovimDynamic;
      VISUAL = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.neovimDynamic;
      NH_FLAKE = "/home/henry/dotfiles";
    };
    environment.systemPackages = with pkgs; [
      kitty
      git
    ];

    services = {
      gvfs.enable = true;
      upower.enable = true;
      udisks2.enable = true;
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --user-menu --cmd start-hyprland";
          };
        };
      };
    };

    # Install firefox.
    programs = {
      firefox.enable = true;
      localsend = {
        enable = true;
        openFirewall = true;
      };
    };

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      ubuntu-sans
      cm_unicode
      corefonts
      unifont
    ];

    fonts.fontconfig.defaultFonts = {
      serif = ["Ubuntu Sans"];
      sansSerif = ["Ubuntu Sans"];
      monospace = ["JetBrainsMono Nerd Font"];
    };

    time.timeZone = "America/New_York";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
}
