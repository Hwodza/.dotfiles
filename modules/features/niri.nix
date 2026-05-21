{ self, inputs, ... }: {
	flake.nixosModules.niri = { config, pkgs, lib, ... }: {
	    programs.niri = {
	      enable = true;
	      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
	    };
	  };
	perSystem = { pkgs, lib, self', ... }: {
		packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap { 
			inherit pkgs;
			settings = {
				spawn-at-startup = [
					(lib.getExe self'.packages.myNoctalia)
				];
				xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

				input = {
					keyboard.xkb.layout = "us,ua";
					touchpad = {
						tap = null;
						natural-scroll = null;
					};
				};

				layout.gaps = 5;

				binds = {
				  "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
				  "Mod+Return".spawn = "kitty";
				  "Mod+Q".close-window = null;
				};
			};
		};
	};
}
