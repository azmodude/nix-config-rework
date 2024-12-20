{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    getExe'
    ;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;
  inherit (config.${namespace}) user;

  cfg = config.${namespace}.security.gpg;

  gpgAgentConf = ''
    enable-ssh-support
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program ${getExe' pkgs.pinentry-gnome3 "pinentry-gnome3"}
  '';
  fetchKey =
    {
      url,
      sha256 ? lib.fakeSha256,
    }:
    builtins.fetchurl { inherit sha256 url; };
in
{
  options.${namespace}.security.gpg = with types; {
    enable = mkBoolOpt false "Whether or not to enable GPG.";
    agentTimeout = mkOpt int 5 "The amount of time to wait before continuing with shell init.";
    enableSshSupport = mkBoolOpt false "Whether or not to enable SSH support for GPG.";
    fetchKey = {
      enable = lib.mkEnableOption "Fetch a key to import from GitHub";
      Url = mkOpt types.str "" "URL to key to fetch from GitHub to import";
      Sha256 = mkOpt types.str "" "SHA256 of key to fetch";
    };
    trustLevel = mkOpt types.int 5 "Trust level for fetched key";
  };
  config = mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.fetchKey.enable -> cfg.fetchKey.Url != "";
            message = "${namespace}.security.gpg.fetchKey.Url must be set if a key is to be fetched.";
          }
          {
            assertion = cfg.fetchKey.enable -> cfg.fetchKey.Sha256 != "";
            message = "${namespace}.security.gpg.fetchKey.Sha256 must be set if a key is to be fetched.";
          }
        ];

        # environment.shellInit = # bash
        #   ''
        #     ${getExe' pkgs.coreutils "timeout"} ${builtins.toString cfg.agentTimeout} ${getExe' pkgs.gnupg "gpgconf"} --launch gpg-agent
        #     gpg_agent_timeout_status=$?
        #
        #     if [ "$gpg_agent_timeout_status" = 124 ]; then
        #       # Command timed out...
        #       echo "GPG Agent timed out..."
        #       echo 'Run "gpgconf --launch gpg-agent" to try and launch it again.'
        #     fi
        #   '';

        # environment.systemPackages = with pkgs; [
        #   cryptsetup
        #   gnupg
        #   paperkey
        #   pinentry-curses
        #   pinentry-qt
        # ];
        programs.gpg = {
          enable = true;
          settings = {
            trust-model = "tofu+pgp";
          };
          publicKeys = mkIf cfg.fetchKey.enable [
            {
              source = fetchKey {
                url = cfg.fetchKey.Url;
                sha256 = cfg.fetchKey.Sha256;
              };
              trust = cfg.trustLevel;
            }
          ];
        };
        services.gpg-agent = {
          enable = true;
          # enableSshSupport = false;
          inherit (cfg) enableSshSupport;
          pinentryPackage = pkgs.pinentry-gnome3;
          enableExtraSocket = true;
        };
        # home.persistence = {
        #   "/persist/home/${user.name}" = {
        #     directories = [".gnupg"];
        #   };
        # };
        # ensure .gnupg is secure
        systemd.user.tmpfiles.rules = [
          "z ${user.home}/.gnupg 0700 ${user.name} ${user.name} - -"
        ];
      }
    ]
  );
}

# programs = {
#   ssh.startAgent = !cfg.enableSSHSupport;
#   gnupg.agent = {
#     enable = true;
#     inherit (cfg) enableSSHSupport;
#     enableExtraSocket = true;
#     pinentryPackage = pkgs.pinentry-gnome3;
#   };
# };

# services = {
#   pcscd.enable = true;
#   udev.packages = with pkgs; [ yubikey-personalization ];
# };
# {
#   pkgs,
#   config,
#   lib,
#   desktop,
#   user,
#   ...
# }: let

# pinentry =
#   if desktop.environment == "plasma"
#   then {
#     package = pkgs.pinentry-qt;
#     name = "qt";
#   }
#   else if desktop.environment == "gnome"
#   then {
#     package = pkgs.pinentry-gnome3;
#     name = "pinentry-gnome3";
#   }
#   else {
#     package = pkgs.pinentry-curses;
#     name = "curses";
#   };
# in {
# home.packages = [pinentry.package];
#
#
# programs = let
#   fixGpg = ''
#     gpgconf --launch gpg-agent
#   '';
# in {
#   # Start gpg-agent if it's not running or tunneled in
#   # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
#   # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
#   bash.profileExtra = fixGpg;
#   #      fish.loginShellInit = fixGpg;
#   zsh.loginExtra = fixGpg;

# # ensure .gnupg is secure
# systemd.user.tmpfiles.rules = [
#   "z /home/${user.name}/.gnupg 0700 ${user.name} ${user.name} - -"
# ];

#
#  # Link /run/user/$UID/gnupg to ~/.gnupg-sockets
#  # So that SSH config does not have to know the UID
#  systemd.user.services.link-gnupg-sockets = {
#    Unit = {
#      Description = "link gnupg sockets from /run to /home";
#    };
#    Service = {
#      Type = "oneshot";
#      ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
#      ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
#      RemainAfterExit = true;
#    };
#    Install.WantedBy = [ "default.target" ];
#  };
# }
# vim: filetype=nix
