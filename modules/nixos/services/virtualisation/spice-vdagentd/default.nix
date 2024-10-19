{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.services.virtualisation.spice-vdagentd;
in
{
  options.${namespace}.services.virtualisation.spice-vdagentd = {
    enable = mkBoolOpt false "Whether or not to configure spice-vdagent support.";
  };

  config = mkIf cfg.enable {
    services.spice-vdagentd.enable = true;
  };
}
