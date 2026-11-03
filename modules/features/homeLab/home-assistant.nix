# modules/home-assistant.nix
{...}: {
  flake.nixosModules.home-assistant = {config, ...}: {
    services.home-assistant = {
      enable = true;

      # Components whose Python deps are built into the HA package.
      # Setting this replaces the module default, so default_config is listed explicitly.
      extraComponents = [
        "default_config"
        "met"
        "mobile_app"
        "zha"
      ];

      config = {
        default_config = {};

        # Behind cloudflared -> 127.0.0.1:8123
        http = {
          # server_host = ["127.0.0.1" "::1"]; # loopback only; remove to also allow LAN access
          server_port = 8123;
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1" "::1"];
        };

        recorder = {
          purge_keep_days = 30;
          commit_interval = 5;
        };

        # UI-managed automations/scenes/scripts live in writable files
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";
      };
    };

    # Serial access for the Sonoff dongle (shows up as ttyUSB/ttyACM)
    users.users.hass.extraGroups = ["dialout"];

    # The !include targets must exist, owned by hass
    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0644 hass hass - []"
      "f ${config.services.home-assistant.configDir}/scenes.yaml 0644 hass hass - []"
      "f ${config.services.home-assistant.configDir}/scripts.yaml 0644 hass hass - {}"
    ];

    # Only needed once you add integrations with API keys. Then reference them
    # in the config as `!secret name`.
    # sops.secrets."home-assistant/secrets.yaml" = {
    #   sopsFile = ../secrets/home-assistant.yaml;
    #   owner = "hass";
    #   path = "${config.services.home-assistant.configDir}/secrets.yaml";
    #   restartUnits = ["home-assistant.service"];
    # };
  };
}
