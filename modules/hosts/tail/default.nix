{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.tail = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.tailConfiguration
    ];
  };

  flake.deploy.nodes.tail = {
    hostname = "192.168.4.51";
    # user = "sudo";
    # sshUser = "tail";
    # sshOpts = ["-i" "/home/henry/.ssh/tail"];
    profiles.system = {
      user = "root";
      sshUser = "tail";
      sshOpts = ["-i" "/home/henry/.ssh/tail"];
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.tail;
      interactiveSudo = true;
      autoRollback = false;
      magicRollback = false;
    };
  };
}
