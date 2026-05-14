{ self, inputs, ... }: {
	flake.nixosModules.niri = { pkgs, lib, ... }: {
	    programs.niri = {
	      enable = true;
	      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
	    };
	  };
	perSystem = { pkgs, lib, ... }: {
		packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap { 
			inherit pkgs;
			settings = {
				xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

				input.keyboard.xkb.layout = "us,ua";

				layout.gaps = 5;

				binds = {
				  "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
				  "Mod+Q".close-window = null;
				};
			};
		};
	};
}
