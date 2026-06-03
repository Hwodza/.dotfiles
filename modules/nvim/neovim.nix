{
  inputs,
  self,
  ...
}: let
  lua = {pkgs, ...}: {
    runtimePkgs = [
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
    runtimePkgs = [pkgs.astro-language-server];

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
    runtimePkgs = [pkgs.rust-analyzer];

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
    runtimePkgs = [
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
  flake.modules.neovim.main = {
    config,
    wlib,
    lib,
    pkgs,
    ...
  }: {
    options = {
      dynamicMode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If true, use impure config instead for fast edits

          Both versions of the package may be installed simultaneously
        '';
      };
      initLua = lib.mkOption {
        type = wlib.types.stringable;
        default = ./.;
      };
      dynamicInitLua = lib.mkOption {
        type = lib.types.either wlib.types.stringable lib.types.luaInline;
        default = lib.generators.mkLuaInline "vim.uv.os_homedir() .. '/.dotfiles/modules/nvim'";
      };
    };
    config = {
      settings.config_directory =
        if config.dynamicMode
        then config.dynamicInitLua
        else config.initLua;

      extraPackages = [
        pkgs.ffmpeg-full
        pkgs.wl-clipboard
        pkgs.fd
        pkgs.ripgrep
      ];

      specs.init = {
        data = null;
        before = ["MAIN_INIT"];
        config = "require('init')";
      };

      specs.plugins = {
        data = [
          pkgs.vimPlugins.lz-n
          pkgs.vimPlugins.plenary-nvim
          pkgs.vimPlugins.nvim-lspconfig
          pkgs.vimPlugins.nvim-treesitter.withAllGrammars
          pkgs.vimPlugins.telescope-nvim

          # completion
          pkgs.vimPlugins.nvim-web-devicons
          pkgs.vimPlugins.lspkind-nvim
          pkgs.vimPlugins.colorful-menu-nvim
          pkgs.vimPlugins.blink-cmp

          # misc
          pkgs.vimPlugins.which-key-nvim
          pkgs.vimPlugins.mini-comment
          pkgs.vimPlugins.snacks-nvim
          pkgs.vimPlugins.oil-nvim
          pkgs.vimPlugins.lualine-nvim
          pkgs.vimPlugins.luasnip
        ];
      };

      specs.lazyPlugins = {
        lazy = true;
        data = [
          pkgs.vimPlugins.lazydev-nvim
          pkgs.vimPlugins.gitsigns-nvim
          pkgs.vimPlugins.nvim-autopairs
          pkgs.vimPlugins.fastaction-nvim
          pkgs.vimPlugins.codecompanion-nvim
        ];
      };

      env.LADSPA_PATH = "${pkgs.deepfilternet}lib/ladspa/libdeep_filter_ladspa.so";
    };
  };

  flake.modules.neovim.lua = lua;
  flake.modules.neovim.astro = astro;
  flake.modules.neovim.rust = rust;
  flake.modules.neovim.nix = nix;

  flake.modules.neovim.allServers = {
    imports = [lua astro rust nix];
  };

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
      inherit pkgs;
      imports = [
        self.modules.neovim.main
        self.modules.neovim.lua
        self.modules.neovim.nix
      ];
    };

    packages.neovimFull = inputs.wrapper-modules.wrappers.neovim.wrap {
      inherit pkgs;
      dynamicMode = true;
      imports = [
        self.modules.neovim.main
        self.modules.neovim.allServers
      ];
    };

    packages.neovimDynamic = inputs.wrapper-modules.wrappers.neovim.wrap {
      inherit pkgs;
      dynamicMode = true;
      imports = [
        self.modules.neovim.main
        self.modules.neovim.allServers
      ];
    };
  };
}
