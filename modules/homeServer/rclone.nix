{...}: {
  flake.nixosModules.rclone = {
    config,
    pkgs,
    ...
  }: let
    userName = config.preferences.user.name;
    dataDir = "/var/lib/rclone-webdav/supernote";
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

    systemd.tmpfiles.rules = [
      "d /var/lib/rclone-webdav 0750 rclone-webdav rclone-webdav -"
      "d ${dataDir} 0750 rclone-webdav rclone-webdav -"
      # Symlink into home for convenient browsing.
      "L+ /home/${userName}/HomeLab/Supernote - - - - ${dataDir}"
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
          ${pkgs.bash}/bin/bash -c '${pkgs.rclone}/bin/rclone serve webdav ${dataDir}/ \
            --addr 127.0.0.1:8081 \
            --user supernote \
            --pass "$(cat ''${CREDENTIALS_DIRECTORY}/rclonepass)"'
        '';
        Restart = "on-failure";
        StateDirectory = "rclone-webdav/supernote";
        ReadWritePaths = [dataDir];
      };
    };
  };
}
