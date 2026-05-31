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
    packages.terminal = let
      shell = lib.getExe self'.packages.environment;
      kitty =
        (inputs.wrappers.wrapperModules.kitty.apply {
          inherit pkgs shell;
          imports = [self.wrappersModules.kitty];
        }).wrapper;
    in
      pkgs.writeShellApplication {
        name = "kitty";
        text = ''
          if [ "$#" -eq 0 ]; then
            exec ${lib.getExe kitty} ${lib.escapeShellArg shell} -i
          fi

          exec ${lib.getExe kitty} "$@"
        '';
      };

    # My primary flake shell with all of it's packages
    packages.environment = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = self'.packages.bash;
      runtimeInputs = with pkgs; [
        # nix
        nil
        nixd
        statix
        alejandra
        manix
        nix-inspect

        # other
        yazi
        file
        unzip
        zip
        p7zip
        wget
        killall
        openssh
        fzf
        htop
        btop
        zoxide
        ripgrep
        fastfetch
        tree-sitter
        lazygit

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
