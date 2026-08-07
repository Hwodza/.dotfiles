{inputs, ...}: {
  flake.nixosModules.mouse = {
    config,
    pkgs,
    ...
  }: {
    # Enable the ratbagd D-Bus daemon for gaming mouse configuration
    services = {
      ratbagd.enable = true;
      input-remapper.enable = true;
    };

    # Expose the graphical frontend to the user environment
    environment.systemPackages = with pkgs; [
      piper
    ];

    # Enable udev rules for Logitech Unifying and Lightspeed receivers
    hardware.logitech.wireless = {
      enable = true;
      # Install Solaar for receiver pairing and battery monitoring
      enableGraphical = true;
    };
  };
}
