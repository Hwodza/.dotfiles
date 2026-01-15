{
  description = "Henry's dotfiles for nixos and home manager";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-workspace2d = {
      url = "github:Hwodza/Hyprland-Workspace-2D";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-index-database,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs-options = {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      # pkgs-unstable = import nixpkgs-unstable pkgs-options;
      workspace2dOverlay = final: prev: {
        hyprland-workspace2d = inputs.hyprland-workspace2d.packages.${prev.system}.workspace2d;
      };
      pkgs = import nixpkgs (
        pkgs-options
        // {
          overlays = [
            workspace2dOverlay
          ];
        }
      );
      pkgs-unstable = import nixpkgs-unstable { inherit system; };
    in
    {
      nixosConfigurations = {
        tester = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./profiles/tester/configuration.nix
          ];
          specialArgs = {
            inherit pkgs-unstable;
          };
        };
        framework = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./profiles/framework/configuration.nix
          ];
          specialArgs = {
            inherit pkgs-unstable;
          };
        };
        pc = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            { nixpkgs.overlays = [ workspace2dOverlay ]; }
            ./profiles/pc/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.henry = {
                imports = [
                  ./profiles/pc/home.nix

                  nix-index-database.homeModules.nix-index
                  { programs.nix-index-database.comma.enable = true; }
                ];
              };
            }
          ];
          specialArgs = {
            inherit pkgs-unstable;
          };
        };
      };
      homeConfigurations = {
        tester = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./profiles/tester/home.nix
            nix-index-database.homeModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
          extraSpecialArgs = {
            inherit pkgs-unstable;
            inherit inputs;
          };
        };
        framework = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./profiles/framework/home.nix
            nix-index-database.homeModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
          extraSpecialArgs = {
            inherit pkgs-unstable;
            inherit inputs;
          };
        };
        pc = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./profiles/pc/home.nix
            nix-index-database.homeModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
          extraSpecialArgs = {
            inherit pkgs-unstable;
            inherit inputs;
          };
        };
      };
    };
}
