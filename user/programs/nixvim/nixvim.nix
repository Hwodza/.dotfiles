{ pkgs, lib, system, ...}:
{
		programs.nixvim = {
				enable = true;
				defaultEditor = true;
		};
}
