{inputs, ...}: {
  flake.nixosModules.nix = {pkgs, ...}: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
      inputs.sops-nix.nixosModules.sops
    ];
    programs.nix-index-database.comma.enable = true;
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      optimise.automatic = true;
      settings.experimental-features = ["nix-command" "flakes"];
    };
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      nil
      nixd
      statix
      alejandra
      manix
      nix-inspect
      sops
    ];
  };
}
