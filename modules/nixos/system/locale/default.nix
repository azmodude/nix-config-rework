{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.system.locale;
in
{
  options.${namespace}.system.locale = {
    enable = mkBoolOpt false "Whether or not to manage locale settings.";
    consoleKeymap = mkOpt lib.types.str "de" "Console keymap to set.";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      # Set locale archive variable in case it isn't being set properly
      LOCALE_ARCHIVE = "/run/current-system/sw/lib/locale/locale-archive";
    };

    i18n.defaultLocale = "en_US.UTF-8";

    console = {
      # TODO: Font stuff probably shouldn't be here
      earlySetup = true;
      font = "ter-powerline-v18n";
      packages = [
        pkgs.terminus_font
        pkgs.powerline-fonts
      ];
      keyMap = cfg.consoleKeymap;
    };
  };
}
