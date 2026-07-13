{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.aiHarness = {
    pkgs,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config = pkgs.config;
    };
  in {
    imports = [self.nixosModules.opencode];

    environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      antigravity-cli
      pkgs.codex
    ];
  };
}
