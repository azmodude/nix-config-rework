{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe;
  cfg = config.${namespace}.programs.graphical.wms.hyprland;
  launcher = pkgs.fuzzel;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        input = {
          follow_mouse = 1;
          kb_layout = "de";
          numlock_by_default = true;
        };
        misc = {
          "$mainMod" = "SUPER";
          "$UBER" = "SUPER_SHIFT";
          "$HYPER" = "SUPER_SHIFT_CTRL";
          "$ALT-HYPER" = "SHIFT_ALT_CTRL";
          "$RHYPER" = "SUPER_ALT_R_CTRL_R";
          "$LHYPER" = "SUPER_ALT_L_CTRL_L";

          "$term" = "${getExe pkgs.kitty}";
          "$launcher" = "${getExe launcher}";
        };
      };
    };
    programs.fuzzel.enable = true;
  };
}
