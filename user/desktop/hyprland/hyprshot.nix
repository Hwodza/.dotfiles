{ pkgs, lib, system, home, config, ... }:
{
	home.packages = with pkgs; [
	 	hyprshot
	];
	home.sessionVariables = {
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  };
	# programs.hyprshot = {
	# 	enable = true;
	# 	saveLocation = "$HOME/Pictures/Screenshots";
	# };

}
