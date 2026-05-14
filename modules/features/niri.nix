{ self, inputs, ... }: {
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
