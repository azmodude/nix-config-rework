{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.${namespace}.programs.graphical.wms.hyprland;
in
{
  options.${namespace}.programs.graphical.wms.hyprland = {
    enable = mkEnableOption "Hyprland.";
    enableDebug = mkEnableOption "Enable debug mode.";
    appendConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra configuration lines to add to bottom of `~/.config/hypr/hyprland.conf`.
      '';
    };
    prependConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra configuration lines to add to top of `~/.config/hypr/hyprland.conf`.
      '';
    };
  };

  imports = lib.snowfall.fs.get-non-default-nix-files ./.;
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd = {
        enable = true;
        variables = [ "--all" ];
      };
    };
    programs.fuzzel.enable = true;
    ${namespace} = {
      programs.graphical.terminals.kitty.enable = true;
    };
  };

}
