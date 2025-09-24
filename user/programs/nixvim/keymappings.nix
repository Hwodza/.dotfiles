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
			{
				mode = "n";
				key = "<leader>lf";
				action = ":lua vim.lsp.buf.format()<CR>";
			}
		];
	};
}
