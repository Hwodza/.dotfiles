{...}: {
  flake.nixosModules.ssh = {...}: {
    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
        Host *
            SetEnv TERM=xterm-256color
        Host github.com
          IdentityFile ~/.ssh/id_github
          IdentitiesOnly yes
      '';
    };
  };
}
