{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkBoolOpt enabled;

  cfg = config.${namespace}.suites.desktop.hyprland;
in
{
  options.${namespace}.suites.desktop.hyprland = {
    enable = mkBoolOpt false "Whether or not to enable common hyprland configuration.";
  };

  config = lib.mkIf cfg.enable {
    ${namespace} = {
      programs = {
        graphical = {
          terminals = {
            kitty.enable = true;
          };
          wms = {
            hyprland = enabled;
          };
        };
      };
    };
  };
}
