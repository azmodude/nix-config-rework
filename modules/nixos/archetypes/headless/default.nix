{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.archetypes.headless;
in
{
  options.${namespace}.archetypes.headless = {
    enable = mkBoolOpt false "Whether or not to enable the headless archetype.";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites = {
        common.enable = true;
      };
    };
  };
}
