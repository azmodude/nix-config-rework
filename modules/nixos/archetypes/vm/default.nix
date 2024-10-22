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
        desktop.enable = true;
        desktop.hyprland.enable = true;
        # development = enabled;
        vm.enable = true;
      };
      display-managers.sddm.enable = true;
    };
  };
}
