{pkgs, ...}: {
  home.packages = [
    pkgs.udiskie
  ];
  services.udiskie = {
    enable = true;
    settings = {
      # workaround for
      # https://github.com/nix-community/home-manager/issues/632
      program_options = {
        # replace with your favorite file manager
        file_manager = "${pkgs.nautilus}/bin/nautilus";
      };
    };
    automount = true;
    tray = "auto";
  };
}
