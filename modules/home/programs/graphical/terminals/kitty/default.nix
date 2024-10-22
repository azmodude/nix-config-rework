{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.programs.graphical.terminals.kitty;
in
{
  options.${namespace}.programs.graphical.terminals.kitty = with types; {
    enable = mkBoolOpt false "Whether to enable kitty.";
    font = mkOpt str "JetBrains Mono Nerd Font" "Font to use for kitty.";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration = {
        enableBashIntegration = true;
        enableFishIntegration = false;
        enableZshIntegration = true;
      };
    };
  };
}
