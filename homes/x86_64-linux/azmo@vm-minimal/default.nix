{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) getExe;
  inherit (lib.${namespace}) enabled;
in
{
  azmo-workstations = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };
  };

  home.packages = [ ];
  programs = {
    bash = {
      enable = true;
    };
  };
  home.stateVersion = "24.11";
}
