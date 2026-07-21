{self, ...}: {
  flake.nixosModules.homeLab-user = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config.preferences.user.name = "server1";
    config.preferences.user.homeDirectory = "/home/server1";

    config.sops.secrets.server1-pubKey = {};

    users.users.server1 = {
      isNormalUser = true;
      description = "server1's account";
      home = "/home/server1";
      extraGroups = [ "wheel" ];
      shell = self.packages.${pkgs.stdenv.hostPlatform.system}.environment;
      openssh.authorizedKeys.keys = [
        (builtins.readFile config.sops.secrets.server1-pubKey.path)
      ];
    };

    home-manager.users.server1 = {
      home.stateVersion = "26.05";
    };
  };
}
