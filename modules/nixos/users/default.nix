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

  cfg = config.${namespace}.users;
  sops-user-password = cfg.name + "-password";
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  options.${namespace}.users = with types; {
    email = mkOpt str "gordon@gordonschulz.de" "The email of the user.";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } "Extra options passed to <option>users.users.<name></option>.";
    fullName = mkOpt str "Gordon Schulz" "The full name of the user.";
    initialPassword =
      mkOpt str "password"
        "The initial password to use when the user is first created.";
    name = mkOpt str "azmo" "The name to use for the user account.";
    gid = mkOpt int 1000 "Primary group of user";
    uid = mkOpt int 1000 "UID of user";
    sshKeys = mkOpt (listOf str) [ ] "SSH Keys for user.";
  };

  config = {
    environment.systemPackages = with pkgs; [
    ];
    sops.secrets = {
      ${sops-user-password} = {
        neededForUsers = true;
      };
    };

    users.groups.${cfg.name} = {
      inherit (cfg) gid;
    };
    users.users.${cfg.name} = {
      inherit (cfg) name;
      # inherit (cfg) initialPassword;
      inherit (cfg) uid;
      hashedPasswordFile = config.sops.secrets.${sops-user-password}.path;
      description = "${cfg.fullName}";
      group = cfg.name;
      isNormalUser = true;
      createHome = true;
      homeMode = "0700";
      shell = pkgs.bash;
      extraGroups =
        [
          "input"
          "wheel"
          "video"
          "audio"
          "users"
        ]
        ++ ifTheyExist [
          "network"
          "networkmanager"
          "wireshark"
          "i2c"
          "mysql"
          "docker"
          "incus-admin"
          "podman"
          "git"
          "libvirtd"
          "syncthing"
        ];

      openssh.authorizedKeys.keys = cfg.sshKeys;
      packages = [ pkgs.home-manager ];
    } // cfg.extraOptions;
  };
}
