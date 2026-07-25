{...}: {
  flake.nixosModules.rclone = {
    config,
    pkgs,
    ...
  }: let
    userName = config.preferences.user.name;
    homeDir = "/home/${userName}";
    supernoteDir = "${homeDir}/HomeLab/Supernote";
  in {
    users.users.rclone-webdav = {
      isSystemUser = true;
      group = "rclone-webdav";
    };
    users.groups.rclone-webdav = {};

    sops.secrets."rclonePass" = {
      owner = "rclone-webdav";
      group = "rclone-webdav";
    };

    # Create the tree with the right ownership, and grant rclone-webdav
    # execute access on the home dir + HomeLab without changing their
    # normal permissions (0700 stays for everyone else).
    systemd.tmpfiles.rules = [
      "d ${homeDir}/HomeLab 0750 ${userName} rclone-webdav -"
      "d ${supernoteDir} 0770 ${userName} rclone-webdav -"
      "a ${homeDir} - - - - u:rclone-webdav:x"
      "a ${homeDir}/HomeLab - - - - u:rclone-webdav:x"
    ];

    systemd.services.rclone-webdav = {
      description = "rclone WebDAV server for Supernote sync";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        User = "rclone-webdav";
        Group = "rclone-webdav";
        LoadCredential = ["rclonepass:${config.sops.secrets."rclonePass".path}"];
        ExecStart = ''
          ${pkgs.bash}/bin/bash -c '${pkgs.rclone}/bin/rclone serve webdav ${supernoteDir}/ \
            --addr 127.0.0.1:8081 \
            --user supernote \
            --pass "$(cat ''${CREDENTIALS_DIRECTORY}/rclonepass)"'
        '';
        Restart = "on-failure";
        ReadWritePaths = [supernoteDir];
      };
    };
  };
}
