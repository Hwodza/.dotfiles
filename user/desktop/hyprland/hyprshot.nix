{ pkgs, ... }:
{
	home.packages = with pkgs; [
		hyprshot
	];
	programs.hyprshot = {
		enable = true;
		saveLocation = "$HOME/Pictures/Screenshots";
	};

}
