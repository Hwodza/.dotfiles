{...}: {
  flake.nixosModules.virtualMachines = {pkgs, ...}: {
    programs.virt-manager.enable = true;
    users.users.henry.extraGroups = ["libvirtd"];
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true; # needed if you want Windows 11 (TPM 2.0 requirement)
          package = pkgs.qemu_kvm;
        };
      };
      spiceUSBRedirection.enable = true;
    };
  };
}
