{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.tuxedo = {
    # inputs,
    pkgs,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config = pkgs.config;
    };
  in {
    environment.systemPackages = [unstablePkgs.tuxedo];
    environment.sessionVariables = {
      TODO_FILE = "/var/lib/sync/todo/todo.txt";
      DONE_FILE = "/var/lib/sync/todo/done.txt";
    };
  };
}
