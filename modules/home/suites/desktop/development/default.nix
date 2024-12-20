{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.suites.development;
in
{
  options.${namespace}.suites.development = {
    enable = mkBoolOpt false "Whether or not to enable common development configuration.";
  };

  config = lib.mkIf cfg.enable {
    ${namespace} = {
      programs = {
        terminal = {
          tools = {
            development = {
              git = {
                enable = true;
              };
            };
          };
        };
      };
    };
  };
}
