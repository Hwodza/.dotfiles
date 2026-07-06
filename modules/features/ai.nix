{inputs, ...}: {
  flake.nixosModules.cloudAI = {pkgs, ...}: let
    system = pkgs.stdenv.hostPlatform.system;
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config = pkgs.config;
    };
  in {
    environment.systemPackages = [
      unstablePkgs.antigravity-cli
    ];
  };
}
