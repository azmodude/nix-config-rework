{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.suites.desktop;
in
{
  options.${namespace}.suites.desktop = {
    enable = mkBoolOpt false "Whether or not to enable common desktop configuration.";
  };

  config = lib.mkIf cfg.enable {
    # ${namespace} = {
    #   programs = {
    #     graphical = {
    #       apps = {
    #         _1password = enabled;
    #       };
    #     };
    #   };
    # };
  };
}
