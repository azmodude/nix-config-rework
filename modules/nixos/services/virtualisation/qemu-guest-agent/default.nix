{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.services.virtualisation.qemu-guest-agent;
in
{
  options.${namespace}.services.virtualisation.qemu-guest-agent = {
    enable = mkBoolOpt false "Whether or not to configure qemu-guest-agent.";
  };

  config = mkIf cfg.enable {
    services.qemuGuest.enable = true;
  };
}
