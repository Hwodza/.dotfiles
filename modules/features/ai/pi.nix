{
  inputs,
  self,
  lib,
  ...
}: {
  flake.homeModules.pi = {
    config,
    pkgs,
    ...
  }: let
    piPath = "${config.home.homeDirectory}/.dotfiles/modules/features/ai/pi";
    system = pkgs.stdenv.hostPlatform.system;
  in {
    home.packages =  [
      inputs.llm-agents.packages.${system}.pi
    ];
    home.file.".pi".source = config.lib.file.mkOutOfStoreSymlink piPath;
  };
}
