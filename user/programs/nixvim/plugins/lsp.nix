{pkgs, ...}: {
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;

        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
            re = "rename";
          };
        };

        servers = {
          gopls.enable = true;
          bashls.enable = true;
          clangd.enable = true;
          lua_ls.enable = true;
          nil_ls.enable = true;
          jsonls.enable = true;
          pyright.enable = true;
          pylsp.enable = true;
          tflint.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
            installRustfmt = true;
          };
        };
      };
      lazydev = {
        enable = true; # autoEnableSources not enough
        settings = {
          library = [
            {
              path = "\${3rd}/luv/library";
              words = ["vim%.uv"];
            }
          ];
        };
      };
      lsp-format = {
        enable = false;
        settings = {
          exclude = ["clangd"];
        };
      };
    };
    extraPackages = with pkgs; [
      rust-analyzer
      rustc
      cargo
    ];
  };
}
