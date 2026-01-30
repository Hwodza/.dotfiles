{ config, ... }:
let
  nvimPath = "${config.home.homeDirectory}/.dotfiles/user/programs/nvim";
  tmuxPath = "${config.home.homeDirectory}/.dotfiles/user/programs/.tmux";
in
{
  imports = [
    # ./nixvim
    ./udiskie.nix
  ];
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimPath;
  xdg.configFile."../.tmux".source = config.lib.file.mkOutOfStoreSymlink tmuxPath;
}
