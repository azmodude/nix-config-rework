{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.archetypes.vm;
in
{
  options.${namespace}.archetypes.vm = {
    enable = mkBoolOpt false "Whether or not to enable the vm archetype.";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites = {
        common.enable = true;
        # desktop = enabled;
        # development = enabled;
        vm.enable = true;
      };
    };
  };
}
