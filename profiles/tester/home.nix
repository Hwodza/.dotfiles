{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "henry";
  home.homeDirectory = "/home/henry";
  imports = [
    # ../../user/desktop/hyprland/hyprland.nix
    ../../user/default.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/henry/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      n = "nvim";
      v = "nvim";
      cd = "z";
      t = "tmux";
    };
    bashrcExtra = ''
      # add ohmyposh
      eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/kushal.omp.json)"

      # Start ssh-agent if not already running and add github id
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_github
      fi
      
      clear

      neofetch

      # Add sesh keybind
      s() {
        sesh connect "$(sesh list | fzf)"
      }

      eval "$(zoxide init bash)"
      '';
  };
  home.file.".tmux.conf".source = ../../.tmux.conf;
  # home.file.".config/hypr/".source = ./.config/hypr;
  home.file.".config/kitty/".source = ../.././.config/kitty;
  home.file.".config/lazygit/".source = ../.././.config/lazygit;
  home.file.".config/neofetch/".source = ../.././.config/neofetch;
  home.file.".config/nvim/".source = ../.././.config/nvim;
  home.file.".config/ohmyposh/".source = ../.././.config/ohmyposh;
  home.file.".config/waybar/".source = ../.././.config/waybar;
  home.file.".config/rofi/".source = ../.././.config/rofi;
  home.file.".config/sesh/".source = ../.././.config/sesh;
  home.file.".config/tmuxinator/".source = ../.././.config/tmuxinator;
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
