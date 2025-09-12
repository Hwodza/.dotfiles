{
  description = "Henry's dotfiles for nixos and home manager";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-workspace2d = {
      url = "github:404wolf/Hyprland-Workspace-2D";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
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
      pkgs = import nixpkgs (
        pkgs-options
        // {
          overlays = [
            (final: prev: {
              hyprland-workspace2d = inputs.hyprland-workspace2d.packages.${system}.workspace2d;
            })
          ];
        }
      );
    in {
      nixosConfigurations = {
        tester = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./profiles/tester/configuration.nix
          ];
        };
      };
      homeConfigurations = {
        tester = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [./profiles/tester/home.nix];
        };
      };
    };
}
