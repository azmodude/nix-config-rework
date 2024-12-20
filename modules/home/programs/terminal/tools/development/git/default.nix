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
    mkEnableOption
    mkIf
    mkForce
    getExe'
    ;
  inherit (lib.${namespace}) mkOpt mkBoolOpt enabled;
  inherit (config.${namespace}) user;

  cfg = config.${namespace}.programs.terminal.tools.development.git;

  # aliases = import ./aliases.nix;
  # ignores = import ./ignores.nix;

in
# tokenExports =
#   lib.optionalString osConfig.${namespace}.security.sops.enable # Bash
#     ''
#       export GITHUB_TOKEN="$(cat ${config.sops.secrets."github/access-token".path})"
#       export GH_TOKEN="$(cat ${config.sops.secrets."github/access-token".path})"
#     '';
{
  options.${namespace}.programs.terminal.tools.development.git = {
    enable = mkEnableOption "Git";
    includes = mkOpt (types.listOf types.attrs) [ ] "Git includeIf paths and conditions.";
    signingMethod = lib.mkOption {
      description = "Signing Method to use (gpg or ssh).";
      type = types.enum [
        "gpg"
        "ssh"
      ];
    };
    signByDefault = mkOpt types.bool true "Whether to sign commits by default.";
    signingKey =
      mkOpt types.str "${config.home.homeDirectory}/.ssh/id_ed25519"
        "The key ID to sign commits with.";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
    wslAgentBridge = mkBoolOpt false "Whether to enable the wsl agent bridge.";
    wslGitCredentialManagerPath =
      mkOpt types.str "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
        "The windows git credential manager path.";
    _1password = mkBoolOpt false "Whether to enable 1Password integration.";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        git-crypt
        git-filter-repo
        git-lfs
        gitflow
        gitleaks
        gitlint
      ]
      ++ lib.optionals config.${namespace}.programs.terminal.tools.fzf.enable [
        pkgs.fzf-git-sh
      ];

    programs = {
      git = {
        enable = true;
        package = pkgs.gitFull;
        inherit (cfg) includes userName userEmail;
        # inherit (aliases) aliases;
        # inherit (ignores) ignores;

        delta = {
          enable = true;

          options = {
            dark = true;
            features = mkForce "decorations side-by-side navigate";
            line-numbers = true;
            navigate = true;
            side-by-side = true;
          };
        };

        extraConfig = {
          credential = {
            helper =
              if cfg.wslAgentBridge then
                cfg.wslGitCredentialManagerPath
              else if pkgs.stdenv.isLinux then
                ''${getExe' config.programs.git.package "git-credential-libsecret"}''
              else
                ''${getExe' config.programs.git.package "git-credential-osxkeychain"}'';

            useHttpPath = true;
          };

          fetch = {
            prune = true;
          };

          gpg = lib.mkMerge [
            (lib.mkIf (cfg.signingMethod == "ssh") {
              format = "ssh";
            })
            (lib.mkIf (cfg.signingMethod == "gpg") {
              format = "gpg";
            })
          ];
          "gpg \"ssh\"".program = mkIf cfg._1password (
            ''''
            + ''${lib.optionalString pkgs.stdenv.isLinux (getExe' pkgs._1password-gui "op-ssh-sign")}''
            + ''${lib.optionalString pkgs.stdenv.isDarwin "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign"}''
          );

          init = {
            defaultBranch = "main";
          };

          lfs = enabled;

          pull = {
            rebase = true;
          };

          push = {
            autoSetupRemote = true;
            default = "current";
          };

          rebase = {
            autoStash = true;
          };

          safe = {
            directory = [
              "~/${namespace}/"
              "/etc/nixos"
            ];
          };
        };

        signing = {
          key = cfg.signingKey;
          inherit (cfg) signByDefault;
        };
      };

      gh = {
        enable = true;

        extensions = with pkgs; [
          gh-dash # dashboard with pull requests and issues
          gh-eco # explore the ecosystem
          gh-cal # contributions calender terminal viewer
          gh-poi # clean up local branches safely
        ];

        gitCredentialHelper = {
          enable = true;
          hosts = [
            "https://github.com"
            "https://gist.github.com"
            "https://dibc@dev.azure.com"
            "https://core-bts-02@dev.azure.com"
          ];
        };

        settings = {
          version = "1";
        };
      };

      # bash.initExtra = tokenExports;
      # fish.shellInit = tokenExports;
      # zsh.initExtra = tokenExports;
    };

    # home = {
    #   inherit (aliases) shellAliases;
    # };

    # sops.secrets = lib.mkIf osConfig.${namespace}.security.sops.enable {
    #   "github/access-token" = {
    #     sopsFile = lib.snowfall.fs.get-file "secrets/khaneliman/default.yaml";
    #     path = "${config.home.homeDirectory}/.config/gh/access-token";
    #   };
    # };
  };
}
