{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.${namespace}.programs.graphical.wms.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        windowrulev2 = [
          # noanimations for launchers
          "noanim, class:^(walker)"
          "noanim, class:^(fuzzel)"
        ];
      };
    };
  };
}
