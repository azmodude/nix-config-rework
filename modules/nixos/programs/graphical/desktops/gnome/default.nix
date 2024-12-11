{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib)
    mkIf
    types
    ;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.programs.graphical.desktops.gnome;

in
{
  options.${namespace}.programs.graphical.desktops.gnome = with types; {
    enable = mkBoolOpt false "Whether or not to enable the Gnome Desktop Environment.";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
