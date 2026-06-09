{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.base = {
    config,
    lib,
    ...
  }: {
    options.preferences.user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "henry";
      };

      homeDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.preferences.user.name}";
      };

      homeStateVersion = lib.mkOption {
        type = lib.types.str;
        default = "26.05";
      };
    };
  };

  flake.nixosModules.home-manager = {config, ...}: let
    user = config.preferences.user;
  in {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs self;
      };

      users.${user.name} = {
        imports = [
          self.homeModules.default
        ];

        home = {
          username = user.name;
          homeDirectory = user.homeDirectory;
          stateVersion = user.homeStateVersion;
        };
      };
    };
  };

  flake.homeModules.base = {
    programs.home-manager.enable = true;
  };

  flake.homeModules.default = {
    imports = [
      self.homeModules.base
    ];
  };
}
