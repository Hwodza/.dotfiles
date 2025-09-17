{ pkgs, ...}:

{
  services.resolved.enable = true;
  networking.resolvconf.enable = false;
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };
  environment.systemPackages = with pkgs; [
    networkmanager-fortisslvpn
    openfortivpn
  ];
}
