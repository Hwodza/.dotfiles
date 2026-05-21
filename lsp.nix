{self, ...}: 
let
	lua = {pkgs, ...}: {
	    extraPackages = [
	      pkgs.lua-language-server
	    ];

	    specs.lua-language-server = {
	      data = [
		pkgs.vimPlugins.nvim-lspconfig
		pkgs.vimPlugins.blink-cmp
	      ];
	      config = ''vim.lsp.enable("lua_ls")'';
	    };
  	};
	astro = {pkgs, ...}: {
	    extraPackages = [pkgs.astro-language-server];

	    specs.astro = {
	      data = [pkgs.vimPlugins.nvim-lspconfig];
	      config =
		#lua
		''
		  vim.lsp.config("astro", {
		    init_options = {
		      typescript = {
			tsdk = "node_modules/typescript/lib",
		      }
		    },
		  })
		  vim.lsp.enable("astro")
		'';
	    };
	};
	rust = {pkgs, ...}: {
	    extraPackages = [pkgs.rust-analyzer];

	    specs.rust = {
	      data = [pkgs.vimPlugins.nvim-lspconfig];
	      config =
		#lua
		''
		  vim.lsp.enable("rust_analyzer")
		'';
	    };
	};
	nix = {pkgs, ...}: {
	    extraPackages = [
	      pkgs.nixd
	      pkgs.alejandra
	    ];

	    specs.nix = {
	      data = [pkgs.vimPlugins.nvim-lspconfig];
	      config =
		#lua
		''
		  vim.lsp.config("nixd", {
		    cmd = { "nixd" },
		    settings = {
		      nixd = {
			nixpkgs = {
			  expr = "import <nixpkgs> { }",
			},
			formatting = {
			  command = { "alejandra" },
			},
		      },
		    },
		  })
		  vim.lsp.enable("nixd")
		'';
	    };
	};
in {
  flake.modules.neovim.lua = lua;

  flake.modules.neovim.astro = astro;

  flake.modules.neovim.rust = rust;

  flake.modules.neovim.nix = nix;

  flake.modules.neovim.allServers = {
    imports = [
      lua
      astro
      rust
      nix
    ];
  };
}
