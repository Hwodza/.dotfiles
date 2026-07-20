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

      runtimePkgs = [
        pkgs.wl-clipboard
        pkgs.fd
        pkgs.ripgrep
        (pkgs.callPackage ../../pkgs/obsidian-headless {})
      ];

      specs.init = {
        data = null;
        before = ["MAIN_INIT"];
        config = "require('init')";
      };

      specs.plugins = {
        data = with pkgs.vimPlugins; [
          lz-n
          nvim-lspconfig
          nvim-treesitter.withAllGrammars
          telescope-nvim

          # completion
          nvim-web-devicons
          lspkind-nvim
          colorful-menu-nvim
          blink-cmp

          # misc
          which-key-nvim
          mini-comment
          mini-surround
          mini-ai
          oil-nvim
          lualine-nvim
          luasnip
          vim-tmux-navigator
        ];
      };

      specs.lazyPlugins = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          lazydev-nvim
          gitsigns-nvim
          nvim-autopairs
          fastaction-nvim
          codecompanion-nvim
          obsidian-nvim
          render-markdown-nvim
          outline-nvim
          autosave-nvim
          markdown-preview-nvim
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
