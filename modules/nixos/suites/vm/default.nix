{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.suites.vm;
in
{
  options.${namespace}.suites.vm = {
    enable = mkBoolOpt false "Whether or not to enable common vm configuration.";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      services = {
        virtualisation = {
          spice-vdagentd.enable = true;
          spice-webdavd.enable = true;
          qemu-guest-agent.enable = true;
        };
      };
    };
  };
}
