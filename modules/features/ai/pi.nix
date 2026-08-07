{
  inputs,
  self,
  lib,
  ...
}: {
  flake.homeModules.pi = {
    config,
    pkgs,
    lib,
    ...
  }: let
    piPath = "${config.home.homeDirectory}/.dotfiles/modules/features/ai/pi/agent";
    pluginsStateDir = "${config.home.homeDirectory}/.local/state/pi-plugins";
    system = pkgs.stdenv.hostPlatform.system;

    originalPi = inputs.llm-agents.packages.${system}.pi;

    # importNpmLock.buildNodeModules derives node_modules directly from the
    # per-package integrity hashes already inside package-lock.json — no
    # separate npmDepsHash to compute or keep in sync.
    #
    # The output of this derivation IS the node_modules directory itself,
    # so ${piExtensionModules} expands to a store path whose contents are
    # the package subdirectories (pi-mcp-adapter/, etc.) directly.
    #
    # Update workflow (the only thing you ever need to run):
    #   cd modules/features/ai/pi/agent/extensions-managed
    #   npm install <package>@<new-version>
    #   add <package> to settings.json
    #   git add package.json package-lock.json
    #   home-manager switch
    piExtensionModules = pkgs.importNpmLock.buildNodeModules {
      npmRoot = self + "/modules/features/ai/pi/agent/extensions-managed";
      nodejs = pkgs.nodejs_22;
    };

    wrappedPi = pkgs.symlinkJoin {
      name = "pi-wrapped";
      paths = [originalPi];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --set NODE_PATH "${pluginsStateDir}/node_modules"
      '';
    };
  in {
    home.packages = [
      wrappedPi
      pkgs.nodejs_22
    ];

    home.file = {
      ".pi/agent/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/settings.json";
      ".pi/agent/mcp.json".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/mcp.json";
      ".pi/agent/models.json".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/models.json";
      ".pi/agent/skills".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/skills";
      ".pi/agent/extensions".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/extensions";
      # ".pi/agent/extensions/pi-permission-system/config.json".source = config.lib.file.mkOutOfStoreSymlink "${piPath}/extensions/pi-permission-system/config.json";
    };

    # The Nix store is read-only, so we copy rather than symlink the built
    # node_modules into a writable state directory. Pi and any npm tooling it
    # spawns (e.g. npx for MCP servers) may write cache/lock metadata at
    # runtime alongside the packages and will get EROFS on a store symlink.
    #
    # This activation block resets the directory to exactly the declared state
    # on every `home-manager switch`. Any ad-hoc `pi install npm:...` done
    # outside of Nix will be wiped on the next switch — intentionally, since
    # pluginsStateDir is the reproducible baseline, not a place for drift.
    home.activation.piExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      target="${pluginsStateDir}/node_modules"

      $DRY_RUN_CMD mkdir -p "${pluginsStateDir}"
      $DRY_RUN_CMD rm -rf  "$target"
      $DRY_RUN_CMD mkdir -p "$target"

      # -L dereferences symlinks in the store path so the copies are plain
      # files and directories the runtime can freely modify.
      $DRY_RUN_CMD cp -rL "${piExtensionModules}/." "$target/"
      $DRY_RUN_CMD chmod -R u+w "$target"
    '';
  };
}
