{inputs, ...}: {
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
  flake.overlays.supernote-tool = final: _prev: let
    python = final.python3;

    potracer = python.pkgs.buildPythonPackage rec {
      pname = "potracer";
      version = "0.0.1";
      format = "setuptools";

      src = python.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "057wz5368nfwklaajdcc738x983978ash8xqnf9b378m614vgf9c";
      };

      propagatedBuildInputs = with python.pkgs; [numpy];
      doCheck = false;
    };
  in {
    supernote-tool = python.pkgs.buildPythonApplication {
      pname = "supernotelib";
      version = "0.7.1";
      pyproject = true;

      # the flake input itself is already a fetched store path, usable as src
      src = inputs.supernote-tool;

      nativeBuildInputs = with python.pkgs; [hatchling];

      propagatedBuildInputs = with python.pkgs; [
        colour
        fusepy
        numpy
        pillow
        potracer
        pypng
        reportlab
        svglib
        svgwrite
      ];

      doCheck = false;
    };
  };

  flake.nixosModules.supernote-tool = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      supernote-tool 
    ];
  };
}
