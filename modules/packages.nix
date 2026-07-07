{
  perSystem = {pkgs, ...}: {
    packages.obsidian-headless = pkgs.callPackage ../pkgs/obsidian-headless {};
  };
}
