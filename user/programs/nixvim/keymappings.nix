{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Keymaps
    keymaps = [
			{
				mode = "n";
				key = "<leader>w";
				action = ":write<CR>";
			}
			{
				mode = "n";
				key = "<leader>q";
				action = ":quit<CR>";
			}
			# {
			# 	mode = "n";
			# 	key = "<leader>lf";
			# 	action = ":lua vim.lsp.buf.format()<CR>";
			# }
      {
        mode = "n";
        key = "<leader>d";
        action = ":lua vim.diagnostic.setloclist()<CR>";
        options = {
          desc = "Open [d]iagnostic quickfix list";
        };
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = ":lua vim.lsp.buf.code_action()<CR>";
        options = {
          desc = "[c]ode [a]ction";
        };
      }
		];
	};
}
