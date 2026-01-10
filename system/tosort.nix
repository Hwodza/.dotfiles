{pkgs, ...}: {
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["henry"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  services.expressvpn.enable = true;

  # TTY login
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Default to Hyprland
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
      plasma = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd startplasma-wayland";
        user = "greeter";
      };
    };
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  boot.kernelModules = ["usb_storage" "uas" "sd_mod" "scsi_mod"];

  environment.systemPackages = with pkgs; [
    vim
    hyprland-workspace2d
    hyprpanel
    rustup
    virt-manager
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
    hyprland
    hyprlock
    hypridle
    firefox
    git
    unzip
    ripgrep
    wl-clipboard
    gcc
    gnumake
    kdePackages.dolphin
    yazi
    gpt-cli
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
    nerd-fonts.symbols-only
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
