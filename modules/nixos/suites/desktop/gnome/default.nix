{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.suites.desktop.gnome;
in
{
  options.${namespace}.suites.desktop.gnome = {
    enable = mkBoolOpt false "Whether or not to enable common hyprland configuration.";
  };

  config = lib.mkIf cfg.enable {
    ${namespace} = {
      programs = {
        graphical = {
          desktops = {
            gnome.enable = true;
          };
        };
      };
    };
  };
}
