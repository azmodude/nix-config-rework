{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.users.root;
in
{
  options.${namespace}.users.root = with types; {
    enable = lib.mkEnableOption "root user";
    extraOptions = mkOpt attrs { } "Extra options passed to <option>users.users.<name></option>.";
    sshKeys = mkOpt (listOf str) [ ] "SSH Keys for root.";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      root-password = {
        neededForUsers = true;
      };
    };

    users.users.root = {
      hashedPasswordFile = config.sops.secrets.root-password.path;
      openssh.authorizedKeys.keys = cfg.sshKeys;
    } // cfg.extraOptions;
  };
}
