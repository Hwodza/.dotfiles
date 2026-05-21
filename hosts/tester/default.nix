{ self, inputs, ... }: {
  flake.nixosConfigurations.tester = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.testerConfiguration
      self.nixosModules.hostTester
    ];
  };
  flake.nixosModules.hostTester = {pkgs, ...}: {
  	imports = [
		self.nixosModules.base
		self.nixosModules.general
	];
  };
}
