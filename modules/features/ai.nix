{inputs, ...}: {
  flake.nixosModules.cloudAI = {pkgs, ...}: let
    system = pkgs.stdenv.hostPlatform.system;
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config = pkgs.config;
    };
  in {
    environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      antigravity-cli
      opencode
      pkgs.codex
    ];
  };
  flake.nixosModules.selfHostedAI = {pkgs, ...}: let
    system = pkgs.stdenv.hostPlatform.system;
    AIpkgs = import inputs.self-hosted-AI-pkgs {
      inherit system;
      config = pkgs.config;
    };
  in {
    environment.systemPackages = [(AIpkgs.llama-cpp.override {cudaSupport = true;})];
  };
}
