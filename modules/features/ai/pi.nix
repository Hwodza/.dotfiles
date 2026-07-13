{
  inputs,
  ...
}: {
  flake.homeModules.pi = {
    config,
    pkgs,
    ...
  }: let
    piSettings = "${config.home.homeDirectory}/.dotfiles/modules/features/ai/pi/agent/settings.json";
    piModels = "${config.home.homeDirectory}/.dotfiles/modules/features/ai/pi/agent/models.json";
    piMCP = "${config.home.homeDirectory}/.dotfiles/modules/features/ai/pi/agent/mcp.json";
    piExtensions = "${config.home.homeDirectory}/.dotfiles/modules/features/ai/pi/agent/extensions";
    system = pkgs.stdenv.hostPlatform.system;
  in {
    home.packages =  [
      inputs.llm-agents.packages.${system}.pi
    ];
    home.file.".pi/agent/settings.json".source = config.lib.file.mkOutOfStoreSymlink piSettings;
    home.file.".pi/agent/models.json".source = config.lib.file.mkOutOfStoreSymlink piModels;
    home.file.".pi/agent/mcp.json".source = config.lib.file.mkOutOfStoreSymlink piMCP;
    home.file.".pi/agent/extensions".source = config.lib.file.mkOutOfStoreSymlink piExtensions;
  };
}
