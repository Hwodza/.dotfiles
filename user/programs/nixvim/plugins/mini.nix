{
  programs.nixvim = {
    plugins.mini = {
      enable = true;
      modules = {
        ai = {
          n_lines = 50;
          search_method = "cover_or_next";
        };
        comment = {
          mappings = {
            comment = "<C-_>";
            comment_line = "<C-_>";
            comment_visual = "<C-_>";
            textobject = "<C-_>";
          };
        };
        surround = {
          mappings = {
            add = "gsa";
            delete = "gsd";
            find = "gsf";
            find_left = "gsF";
            highlight = "gsh";
            replace = "gsr";
            update_n_lines = "gsn";
          };
        };
        statusline = {};
        pairs = {};
      };
    };
  };
}
