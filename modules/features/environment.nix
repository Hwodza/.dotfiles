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
    packages.environment =
      (pkgs.writeShellApplication {
        name = "environment";
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
          tmux
          file
          unzip
          zip
          p7zip
          jq
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
        text = ''
          export EDITOR=${lib.escapeShellArg (lib.getExe self'.packages.neovimDynamic)}
          exec ${lib.getExe self'.packages.bash} "$@"
        '';
      })
      .overrideAttrs (old: {
        passthru = (old.passthru or {}) // {
          shellPath = "/bin/environment";
        };
      });

    # packages.nix-check-bin = pkgs.writeShellApplication {
    #   name = "nix-check-bin";
    #   text = ''
    #     $EDITOR "$(nix build "$1" --no-link --print-out-paths)/bin"
    #   '';
    # };
  };
}
