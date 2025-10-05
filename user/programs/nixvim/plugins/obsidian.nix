{
  programs.nixvim = {
    plugins.obsidian = {
      enable = true;
      settings = {
        completion = {
          min_chars = 2;
          blink = true;
        };
        new_notes_location = "current_dir";
        workspaces = [
          {
            name = "The Vault";
            path = "~/Documents/The Vault/";
          }
        ];
        templates.subdir = "~/Documents/The Vault/5-Templates/";
      };
    };
  };
}
