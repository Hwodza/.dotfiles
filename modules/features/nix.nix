{inputs, ...}: {
  flake.nixosModules.nix = {pkgs, ...}: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];
    programs.nix-index-database.comma.enable = true;
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
        nil
        nixd
        statix
        alejandra
        manix
        nix-inspect
    ];
  };
}
