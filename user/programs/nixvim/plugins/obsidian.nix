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
      };
    };
  };
}
