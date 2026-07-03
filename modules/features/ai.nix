{...}: {
  flake.nixosModules.cloudAI = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      gemini-cli
    ];
  };
}
