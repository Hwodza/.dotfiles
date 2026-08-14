{...}: {
  flake.nixosModules.syncthing = {config, ...}: let
    syncPath = "/var/lib/sync";
    homeSyncLink = "${config.preferences.user.homeDirectory}/sync";
  in {
    sops.secrets."syncthingGuiPass" = {
      owner = config.services.syncthing.user;
      group = config.services.syncthing.group;
    };
    users.groups.syncshare = {};
    users.users.${config.preferences.user.name}.extraGroups = ["syncshare"];
    users.users.${config.services.syncthing.user}.extraGroups = ["syncshare"];

    systemd.tmpfiles.rules = [
      "d ${syncPath} 2770 ${config.preferences.user.name} syncshare -"
      "d ${syncPath}/Documents 2770 ${config.preferences.user.name} syncshare -"
      "d ${syncPath}/todo 2770 ${config.preferences.user.name} syncshare -"
      "L+ ${homeSyncLink} - - - - ${syncPath}"
    ];

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "127.0.0.1:8384";
      guiPasswordFile = "${config.sops.secrets."syncthingGuiPass".path}";
      settings = {
        gui = {
          user = "${config.preferences.user.name}";
        };
        devices = {
          "pc" = {id = "V66CMBP-VA272KR-R26JLIG-4FQQI2Q-ROMUPDF-TOXIQIP-QOERQFW-R4QWFA5";};
          "iphone" = {id = "6B3IUKH-DCGPSSM-63ONWC7-AZTHPQV-QIMXSMC-UTWXCFQ-RNJNIMP-7DUBMA7";};
          "framework" = {id = "NL5XTR3-Y7E4SWR-UPGUNEY-N3RWNEG-KPD6IXS-Q4X6MR4-2AJTF5K-Y77LDQ4";};
          "homeLab" = {id = "ZEQXQHI-FDPGGHW-K75ENKC-WDNNE3V-3W2VLGT-DHQCZM2-B55GYXI-EX6EQQ3";};
        };
        folders = {
          "Documents" = {
            path = "${syncPath}/Documents";
            devices = ["pc" "framework" "homeLab"];
          };
          "todo" = {
            path = "${syncPath}/todo";
            devices = ["pc" "iphone" "framework" "homeLab"];
            ignorePerms = true;
          };
        };
      };
    };
    networking.firewall.allowedTCPPorts = [8384];
  };
}
