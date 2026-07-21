{ self, inputs, ... }: {
  flake.nixosConfigurations.homeLab = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.homeLabConfiguration
    ];
  };
}
