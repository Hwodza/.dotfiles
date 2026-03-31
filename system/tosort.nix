{
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "henry" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  services.expressvpn.enable = true;

  # TTY login
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Default to Hyprland
        command = "${pkgs.tuigreet}/bin/tuigreet --time --user-menu --cmd Hyprland";
        user = "greeter";
      };
      plasma = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd startplasma-wayland";
        user = "greeter";
      };
    };
  };

  services.xserver.xkb = {
    options = "caps:none";
    layout = "us";
  };
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  boot.kernelModules = [
    "usb_storage"
    "uas"
    "sd_mod"
    "scsi_mod"
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    font-awesome
  ];

  services.ollama = {
    enable = true;
    loadModels = [
      "llama3.1:8b"
      "qwen3.5:9b"
      "nomic-embed-text-v2-moe"
    ];
    package = pkgs-unstable.ollama-cuda;
  };

  services.open-webui = {
    enable = true;
  };

  services.searx = {
    enable = true;
    settingsFile = config.sops.templates."searx-settings.yml".path;
    settings = {
      engines = [
        {
          name = "google news";
          engine = "google_news";
          categories = "news";
          language = "en";
          enabled = true;
        }
        {
          name = "bing news";
          engine = "bing_news";
          categories = "news";
          enabled = true;
        }
        {
          name = "duckduckgo";
          engine = "duckduckgo";
          categories = "general";
          enabled = true;
        }
        {
          name = "brave";
          engine = "brave";
          categories = "general";
          enabled = true;
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    hyprland-workspace2d
    hyprpanel
    nwg-displays
    nvtopPackages.full
    rustup
    virt-manager
    claude-code
    ironbar
    nautilus
    wget
    kitty
    libclang
    expressvpn
    swww
    killall
    neovim
    waybar
    rofi
    wl-clipboard
    dbeaver-bin
    typst
    tinymist
    calibre
    imagemagick
    astro-language-server
    vscode
    hyprland
    hyprlock
    hypridle
    firefox
    git
    unzip
    nil
    ripgrep
    wl-clipboard
    gcc
    gnumake
    kdePackages.dolphin
    yazi
    gpt-cli
    tor-browser
    brightnessctl
    python314
    python313
    tmux
    tmuxinator
    neofetch
    obsidian
    nixd
    blueman
    bluez
    fastfetch
    curl
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    font-awesome
    wlogout
    stow
    lua
    smplayer
    lazygit
    anki
    hyprpicker
    zathura
    poppler
    obs-studio
    lua-language-server
    jellyfin
    jellyfin-web
    zoom-us
    btop
    go
    gopls
    google-chrome
    pavucontrol
    powertop
    qutebrowser
    unzip
    element-desktop
    jq
    vscode-langservers-extracted
    prettierd
    bash-language-server
    luajitPackages.luarocks-nix
    jellyfin-ffmpeg
    oh-my-posh
    networkmanagerapplet
    hyprpaper
    discord
    spotify
    sesh
    zoxide
    fzf
    alsa-utils
  ];
}
