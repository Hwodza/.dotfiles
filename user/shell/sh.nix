{ ... }:
{
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

      export HYPRSHOT_DIR="$HOME/Pictures/Screenshots/"
      eval "$(zoxide init bash)"
      '';
  };
}
