{
  programs.nixvim = {
    autoGroups = {
      kickstart-highlight-yank = {
        clear = true;
      };
      auto-view = {
        clear = true;
      };
    };
    autoCmd = [
      # Highlight when yanking (copying) text
      #  Try it with `yap` in normal mode
      #  See `:help vim.hl.on_yank()`
      {
        event = [ "TextYankPost" ];
        desc = "Highlight when yanking (copying) text";
        group = "kickstart-highlight-yank";
        callback.__raw = ''
          function()
            vim.hl.on_yank()
          end
        '';
      }
      {
        event = [ "BufWinLeave" "BufWritePost" "WinLeave" ];
        desc = "Save view with mkview for real files";
        group = "auto-view";
        callback.__raw = ''
          function(args)
            if vim.b[args.buf].view_activated then vim.cmd.mkview { mods = { emsg_silent = true } } end
          end
        '';
      }
      {
        event = [ "BufWinEnter" ];
        desc = "Try to load file view if available and enable view saving for real files";
        group = "auto-view";
        callback.__raw = ''
          function(args)
            if not vim.b[args.buf].view_activated then
              local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
              local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
              local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
              if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
                vim.b[args.buf].view_activated = true
                vim.cmd.loadview { mods = { emsg_silent = true } }
              end
            end
          end
        '';
      }
    ];
  };
}

