{
	programs.nixvim.plugins = {
		oil = {
			enable = true;
			settings = {
				skip_confirm_for_simple_edits = true;
				keymaps = [
					{
						mode = "n";
						key = "g?";
						action = "actions.show_help";
					}
					{
						key = "<CR>";
						action = "actions.select";
					}
				];
			};
		};
	};
}
