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
    piPath = "${config.home.homeDirectory}/.dotfiles/modules/features/ai/pi/agent";
    pluginsStateDir = "${config.home.homeDirectory}/.local/state/pi-plugins";
    system = pkgs.stdenv.hostPlatform.system;

    originalPi = inputs.llm-agents.packages.${system}.pi;
    wrappedPi = pkgs.symlinkJoin {
      name = "pi-wrapped";
      paths = [ originalPi ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --set NODE_PATH "${pluginsStateDir}/node_modules"
      '';
    };
  in {
    home.packages = [
      wrappedPi
      pkgs.nodejs
    ];

    home.activation = {
      installPiPlugins = config.lib.dag.entryAfter ["writeBoundary"] ''
        export PATH="${pkgs.nodejs}/bin:$PATH"
        mkdir -p "${pluginsStateDir}"
        cd "${pluginsStateDir}"
        cat << 'PKGJSON' > package.json
        {
          "name": "pi-plugins",
          "version": "1.0.0",
          "dependencies": {
            "pi-mcp-adapter": "latest",
            "@gotgenes/pi-permission-system": "latest"
          }
        }
PKGJSON
        npm install
      '';
    };

    home.file = {
      ".pi/agent/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/settings.json";
      ".pi/agent/mcp.json".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/mcp.json";
      ".pi/agent/models.json".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/models.json";
      ".pi/agent/extensions/pi-permission-system/config.json".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/extensions/pi-permission-system/config.json";
    };
  };
}
