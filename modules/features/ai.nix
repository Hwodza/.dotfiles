{inputs, ...}: {
  flake.nixosModules.cloudAI = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.nixpkgs-unstable.antigravity-cli
    ];
  };
}
