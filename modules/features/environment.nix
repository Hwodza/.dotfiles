{
  lib,
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    # My whole desktop in one package, includes kityy terminal
    # packages.desktop = inputs.wrapper-modules.wrappers.niri.wrap {
    #   inherit pkgs;
    #   imports = [self.wrappersModules.niri];
    #   terminal = lib.getExe self'.packages.terminal;
    #   env = {
    #     EDITOR = lib.getExe self'.packages.neovim;
    #   };
    # };

    # My primary flake terminal
    packages.terminal =
      (inputs.wrappers.wrapperModules.kitty.apply {
        inherit pkgs;
        imports = [self.wrappersModules.kitty];
        shell = lib.getExe self'.packages.environment;
      }).wrapper;

    # My primary flake shell with all of it's packages
    packages.environment = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = self'.packages.bash;
      runtimeInputs = [
        # nix
        pkgs.nil
        pkgs.nixd
        pkgs.statix
        pkgs.alejandra
        pkgs.manix
        pkgs.nix-inspect

        # other
        pkgs.file
        pkgs.unzip
        pkgs.zip
        pkgs.p7zip
        pkgs.wget
        pkgs.killall
        pkgs.openssh
        pkgs.fzf
        pkgs.htop
        pkgs.btop
        pkgs.zoxide
        pkgs.ripgrep
        pkgs.fastfetch
        pkgs.tree-sitter
        pkgs.lazygit

        # wrapped
        self'.packages.neovimDynamic
        # self'.packages.qalc
        # self'.packages.lf
        self'.packages.git
        # self'.packages.jujutsu
        # self'.packages.jjui
        # self'.packages.nix-check-bin
      ];
      env = {
        EDITOR = lib.getExe self'.packages.neovimDynamic;
      };
    };

    # packages.nix-check-bin = pkgs.writeShellApplication {
    #   name = "nix-check-bin";
    #   text = ''
    #     $EDITOR "$(nix build "$1" --no-link --print-out-paths)/bin"
    #   '';
    # };
  };
}
