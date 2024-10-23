{
  config,
  inputs,
  lib,
  pkgs,
  osConfig,
  namespace,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.${namespace}.themes.catppuccin;

  catppuccinAccents = [
    "rosewater"
    "flamingo"
    "pink"
    "mauve"
    "red"
    "maroon"
    "peach"
    "yellow"
    "green"
    "teal"
    "sky"
    "sapphire"
    "blue"
    "lavender"
  ];

  catppuccinFlavors = [
    "latte"
    "frappe"
    "macchiato"
    "mocha"
  ];
in
{
  options.${namespace}.themes.catppuccin = {
    enable = mkEnableOption "Enable catppuccin theme for applications.";

    accent = mkOption {
      type = types.enum catppuccinAccents;
      default = "blue";
      description = ''
        An optional theme accent.
      '';
    };

    flavor = mkOption {
      type = types.enum catppuccinFlavors;
      default = "macchiato";
      description = ''
        An optional theme flavor.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.catppuccin.override {
        inherit (cfg) accent;
        variant = cfg.flavor;
      };
    };
  };

  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];
  config = mkIf cfg.enable {

    catppuccin = {
      enable = false;
      inherit (cfg) accent;
      inherit (cfg) flavor;
      pointerCursor = mkIf (!osConfig.${namespace}.archetypes.headless.enable) {
        enable = true;
        inherit (cfg) accent;
        inherit (cfg) flavor;
      };
    };
    gtk = mkIf (!osConfig.${namespace}.archetypes.headless.enable) {
      catppuccin = {
        enable = true;
        inherit (cfg) accent;
        inherit (cfg) flavor;
        icon = {
          enable = true;
          inherit (cfg) accent;
          inherit (cfg) flavor;

        };

      };
    };
    programs.kitty = mkIf config.${namespace}.programs.graphical.terminals.kitty.enable {
      catppuccin = {
        enable = true;
        inherit (cfg) flavor;

      };
    };
    programs.fuzzel = mkIf config.${namespace}.programs.graphical.wms.hyprland.enable {
      catppuccin = {
        enable = true;
        inherit (cfg) accent;
        inherit (cfg) flavor;
      };
    };
    wayland.windowManager.hyprland = mkIf config.${namespace}.programs.graphical.wms.hyprland.enable {
      catppuccin = {
        enable = true;
        inherit (cfg) accent;
        inherit (cfg) flavor;

      };
    };
  };
}
