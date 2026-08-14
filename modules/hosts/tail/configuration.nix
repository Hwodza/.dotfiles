{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.tailConfiguration = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.tailHardware
      self.nixosModules.base
      # self.nixosModules.home-manager
      self.nixosModules.nix
      # self.nixosModules.tail-user
      # self.nixosModules.ssh
      self.nixosModules.tail-cloudflare
      self.nixosModules.tail
    ];

    # home-manager.users.tail.imports = [
    #   self.homeModules.tail
    # ];
    # home-manager.users.tail = {
    #   home.stateVersion = "26.05";
    # };

    security.sudo.extraRules = [
      {
        groups = ["tail" "wheel"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "tail";

    # Enable networking
    networking.networkmanager.enable = true;
    nix.settings.trusted-users = ["tail"];

    # Set your time zone.
    time.timeZone = "America/New_York";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    sops.secrets.tail-pubKey = {};
    users.users.tail = {
      isNormalUser = true;
      description = "tail";
      extraGroups = ["networkmanager" "sudo" "wheel"];
      packages = with pkgs; [];
      shell = self.packages.${pkgs.stdenv.hostPlatform.system}.environment;
      openssh.authorizedKeys.keys = [
        "$(cat ${config.sops.secrets.tail-pubKey.path})"
      ];
    };
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    systemd.services.NetworkManager.restartIfChanged = false;
    systemd.services.NetworkManager.stopIfChanged = false;
    # also worth doing for its dependents:
    systemd.services.wpa_supplicant.restartIfChanged = false;

    # Open ports in the firewall.
    networking.firewall = {
      allowedTCPPorts = [22 443];
      checkReversePath = "loose";
    };

    # Keep the lid from suspending when closed.'
    services.logind.settings.Login.HandleLidSwitch = "ignore";

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on this system were taken.
    system.stateVersion = "25.05";
  };
}
