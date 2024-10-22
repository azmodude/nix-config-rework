{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib)
    mkIf
    types
    ;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;
  inherit (inputs) hyprland;

  cfg = config.${namespace}.programs.graphical.wms.hyprland;

in
{
  options.${namespace}.programs.graphical.wms.hyprland = with types; {
    enable = mkBoolOpt false "Whether or not to enable Hyprland.";
    customConfigFiles =
      mkOpt attrs { }
        "Custom configuration files that can be used to override the default files.";
    customFiles = mkOpt attrs { } "Custom files that can be used to override the default files.";
    wallpaper = mkOpt (nullOr package) null "The wallpaper to display.";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
