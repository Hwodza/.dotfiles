{...}: {
  flake.nixosModules.ssh = {...}: {
    programs.ssh = {
      startAgent = true;
      # extraConfig = ''
      #   AddKeysToAgent yes
      #   Host *
      #       SetEnv TERM=xterm-256color
      #   Host github.com
      #     IdentityFile ~/.ssh/id_github
      #     IdentitiesOnly yes
      # '';
    };
  };
  flake.homeModules.ssh = {...}: {
    programs.ssh = {
      enable = true;
      settings = {
        "*" = {
          AddKeysToAgent = "yes";
        };
        "Host *" = {
          SetEnv = {TERM = "xterm-256color";};
        };

        "Host github.com" = {
          IdentityFile = "~/.ssh/id_github";
          IdentitiesOnly = "yes";
        };

        "Host homelab" = {
          HostName = "server1.odza.dev";
          User = "server1";
          ProxyCommand = "cloudflared access ssh --hostname %h";
          IdentityFile = "~/.ssh/id_server1";
          IdentitiesOnly = "yes";
        };

        "Host tail" = {
          HostName = "tail.odza.dev";
          User = "tail";
          ProxyCommand = "cloudflared access ssh --hostname %h";
          IdentityFile = "~/.ssh/id_tail";
          IdentitiesOnly = "yes";
        };
      };
    };
  };
}
