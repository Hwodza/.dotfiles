{...}: {
  flake.nixosModules.ssh = {...}: {
    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };
}
