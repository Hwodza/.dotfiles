{ self, inputs, ... }: {
  flake.nixosConfigurations.tester = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.testerConfiguration
    ];
  };
  flake.nixosModules.hostTester = {pkgs, ...}: {
  	imports = [
		self.nixosModules.base
	];
  };
}
