{self, ...}: {
  flake.nixosModules.tail-user = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config.preferences.user.name = "tail";
    config.preferences.user.homeDirectory = "/home/tail";

    config.sops.secrets.tail-pubKey = {};

    config.users.users.tail = {
      isNormalUser = true;
      description = "tail's account";
      home = "/home/tail";
      extraGroups = ["wheel" "sudo" "networkmanager"];
      shell = self.packages.${pkgs.stdenv.hostPlatform.system}.environment;
      openssh.authorizedKeys.keys = [
        "$(cat ${config.sops.secrets.tail-pubKey.path})"
      ];
    };
  };
}
