{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkOption
    ;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.services.virtualisation.spice-webdavd;
in
{
  options.${namespace}.services.virtualisation.spice-webdavd = with types; {
    enable = mkBoolOpt false "Whether or not to configure spice-webdav proxy support.";
    package = mkOption {
      default = pkgs.phodav;
      defaultText = literalExpression "pkgs.phodav";
      description = lib.mdDoc "spice-webdavd provider package to use.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    services = {
      spice-webdavd = {
        enable = true;
        inherit package;
      };
    };
  };
}
