{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    networkmanager-fortisslvpn
  ];
}
