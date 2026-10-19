{...}: {
  flake.nixosModules.microbin = {...}: {
    services.microbin = {
      enable = true;
      settings = {
        MICROBIN_BIND = "0.0.0.0";
        MICROBIN_PORT = "8090";
      };
    };
  };
}
