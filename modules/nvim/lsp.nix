{self, ...}: {
  flake.modules.neovim.lua = {pkgs, ...}: {
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

  flake.modules.neovim.astro = {pkgs, ...}: {
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

  flake.modules.neovim.rust = {pkgs, ...}: {
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

  flake.modules.neovim.nix = {pkgs, ...}: {
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

  flake.modules.neovim.allServers = {
    imports = [
      self.modules.neovim.lua
      self.modules.neovim.astro
      self.modules.neovim.rust
      self.modules.neovim.nix
    ];
  };
}
