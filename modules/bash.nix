{
inputs,
...
}: {
  perSystem = {
    pkgs,
    ...
  }: let 
    bashrc = pkgs.writeText "bashrc" ''
      PS1='\u@\h:\w\$ '
      # Start ssh-agent if not already running and add github id
      if [ -z "SSS_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)"
      fi
      ssh-add ~/.ssh/id_github
      clear
      fastfetch
    '';
    in {
      packages.bash = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.bash;
        flags = {
          "--rcfile" = "${bashrc}";
        };
      };
    };
}
