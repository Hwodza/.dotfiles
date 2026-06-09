{self, ...}: {
  flake.homeModules.desktop = {pkgs, ...}: {
    home.packages = with pkgs; [
      kdePackages.dolphin
      tor-browser
      obsidian
      zathura
      poppler
      obs-studio
      discord
      spotify
    ];
  };

  flake.nixosModules.desktop = {
    config,
    pkgs,
    lib,
    ...
  }: let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in {
    # imports = [
    #   self.nixosModules.hypr
    #   {
    #     my.hyprland.package = self.packages.${pkgs.system}.myHyprland;
    #   }
    # ];

    home-manager.users.${config.preferences.user.name}.imports = [
      self.homeModules.desktop
      self.homeModules.hypr
    ];
    environment.sessionVariables.TERMINAL = lib.getExe selfpkgs.terminal;
    environment.systemPackages = with pkgs; [
      selfpkgs.terminal
      vscode
      git
    ];

    services = {
      upower.enable = true;
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
    programs.firefox.enable = true;

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
