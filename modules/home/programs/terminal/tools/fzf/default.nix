{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.programs.terminal.tools.fzf;
in
{
  options.${namespace}.programs.terminal.tools.fzf = {
    enable = mkBoolOpt false "Whether or not to enable fzf.";
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      defaultCommand = "${lib.getExe pkgs.fd} --type=f --hidden --exclude=.git";
      defaultOptions = ["--height 60%" "--border=rounded"];
      fileWidgetOptions = ["--preview '${lib.getExe pkgs.bat} -n --color=always {}'" "--preview-window=right:50%:wrap"];
      changeDirWidgetCommand = "${lib.getExe pkgs.fd} --type d --exclude .git";

      enableBashIntegration = true;
      enableZshIntegration = true;

      tmux = {
        enableShellIntegration = true;
      };
    };
  };
}
