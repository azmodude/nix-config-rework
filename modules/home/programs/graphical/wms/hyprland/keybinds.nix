{
  config,
  lib,
  pkgs,
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
        # NOTE: different bind flags
        # l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
        # r -> release, will trigger on release of a key.
        # e -> repeat, will repeat when held.
        # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
        # m -> mouse, Mouse binds are binds that rely on mouse movement. They will have one less arg
        # t -> transparent, cannot be shadowed by other binds.
        # i -> ignore mods, will ignore modifiers.
        # "$mainMod" = "SUPER";
        # "$HYPER" = "SUPER_SHIFT_CTRL";
        # "$ALT-HYPER" = "SHIFT_ALT_CTRL";
        # "$RHYPER" = "SUPER_ALT_R_CTRL_R";
        # "$LHYPER" = "SUPER_ALT_L_CTRL_L";
        bind = [
          # launcher
          #            "$mainMod, SPACE, exec, run-as-service $($launcher)"
          "$mainMod, SPACE, exec, run-as-service $($launcher)"
          "CTRL, SPACE, exec, run-as-service $($launcher)"
          # apps
          "$mainMod, RETURN, exec, $term"
          # kill window
          "$UBER, Q, killactive"
        ];
        bindl = [
          # Kill and restart crashed hyprlock
          "$mainMod, BackSpace, exec, pkill -SIGUSR1 hyprlock || WAYLAND_DISPLAY=wayland-1 $screen-locker --immediate"
          "$LHYPER, L, exec, ${pkgs.systemd}/bin/systemctl --user exit"
          "$LHYPER, L, exit,"
          "$LHYPER, R, exec, ${pkgs.systemd}/bin/systemctl reboot"
          "$LHYPER, P, exec, ${pkgs.systemd}/bin/systemctl poweroff"
        ];
      };
    };
  };
}
