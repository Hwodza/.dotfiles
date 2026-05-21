{ self, inputs, ... }: {
  flake.nixosConfigurations.tester = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.testerConfiguration
    ];
  };
}
