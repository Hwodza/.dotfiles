{self, ...}: {
  flake.nixosModules.homeServer = {pkgs, ...}: {
    imports = [
      self.nixosModules.cloudflare
      self.nixosModules.rclone
      self.nixosModules.miniflux
    ];
  };

  flake.nixosModules.miniflux = {config, ...}: {
    sops.secrets."miniflux" = {};
    services.miniflux = {
      enable = true;
      adminCredentialsFile = "${config.sops.secrets."miniflux".path}";
    };
  };

  flake.nixosModules.cloudflare = {
    inputs,
    config,
    pkgs,
    ...
  }: {
    sops.secrets."cloudflareTunnelhomeLab1" = {};
    services.cloudflared = {
      enable = true;
      tunnels = {
        "7fa77531-bf82-4583-818d-51a588c68614" = {
          credentialsFile = "${config.sops.secrets."cloudflareTunnelhomeLab1".path}";
          default = "http_status:404";
          ingress = {
            "supernote.odza.dev" = "http://127.0.0.1:8081";
            "miniflux.odza.dev" = "http://127.0.0.1:8080";
          };
        };
      };
    };
  };
  # flake.nixosModules.caddy = {...}: {
  #   services.caddy = {
  #     enable = true;
  #     virtualHosts = {
  #       "supernote.odza.dev" = {
  #         extraConfig = ''
  #           reverse_proxy http://127.0.0.1:8080
  #         '';
  #       };
  #     };
  #   };
  # };
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
