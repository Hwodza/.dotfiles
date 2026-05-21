{self, ...}: {
	flake.nixosModules.general = {
		pkgs,
		config,
	}: {
		users.users.${config.preferences.user.name} = {
			isNormalUser = true;
			description = "${config.preferences.user.name}'s account";
			extraGroups = ["wheel" "networkmanager"];
			shell = self.packages.${pkgs.system}.environment;
		};
	};
}
