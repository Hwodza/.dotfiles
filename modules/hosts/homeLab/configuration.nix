{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.homeLabConfiguration = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.homeLabHardware
      self.nixosModules.base
      self.nixosModules.home-manager
      self.nixosModules.nix
      self.nixosModules.homeLab-user
      self.nixosModules.ssh
      self.nixosModules.homeServer
    ];

    home-manager.users.server1.imports = [
      self.homeModules.server1
    ];
    home-manager.users.server1 = {
      home.stateVersion = "26.05";
    };

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "homeLab";

    # Enable networking
    networking.networkmanager.enable = true;

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [22 443];

    # Keep the lid from suspending when closed.'
    services.logind.settings.Login.HandleLidSwitch = "ignore";

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on this system were taken.
    system.stateVersion = "25.11";
  };
}
