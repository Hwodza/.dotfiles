{
  description = "Henry's dotfiles for nixos and home manager";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-workspace2d = {
      url = "github:404wolf/Hyprland-Workspace-2D";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
