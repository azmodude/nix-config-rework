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
    mkDefault
    mkMerge
    getExe
    getExe'
    ;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.user;

  home-directory =
    if cfg.name == null then
      null
    else if pkgs.stdenv.isDarwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";
in
{
  options.${namespace}.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    email = mkOpt types.str "gordon@gordonschulz.de" "The email of the user.";
    fullName = mkOpt types.str "Gordon Schulz" "The full name of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
    # icon =
    #   mkOpt (types.nullOr types.package) pkgs.${namespace}.user-icon
    #     "The profile picture to use for the user.";
    name = mkOpt (types.nullOr types.str) config.snowfallorg.user.name "The user account.";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "${namespace}.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "${namespace}.user.home must be set";
        }
      ];

      home = {
        file = {
          "Desktop/.keep".text = "";
          "Documents/.keep".text = "";
          "Downloads/.keep".text = "";
          "Music/.keep".text = "";
          "Pictures/.keep".text = "";
          "Videos/.keep".text = "";
        };
        # // lib.optionalAttrs (cfg.icon != null) {
        #   ".face".source = cfg.icon;
        #   ".face.icon".source = cfg.icon;
        #   "Pictures/${cfg.icon.fileName or (builtins.baseNameOf cfg.icon)}".source = cfg.icon;
        # };

        homeDirectory = mkDefault cfg.home;
        preferXdgDirectories = mkDefault true;

        shellAliases = {
          # nix specific aliases
          cleanup = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
          bloat = "nix path-info -Sh /run/current-system";
          curgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
          gc-check = "nix-store --gc --print-roots | egrep -v \"^(/nix/var|/run/\w+-system|\{memory|/proc)\"";
          repair = "nix-store --verify --check-contents --repair";
          run = "nix run";
          search = "nix search";
          shell = "nix shell";
          nixre = "${lib.optionalString pkgs.stdenv.isLinux "sudo"} flake switch";
          # TODO: figure out how to make this nix flake check compatible
          # nixre = "${lib.optionalString pkgs.stdenv.isLinux "sudo"} ${
          #   getExe snowfall-flake.packages.${system}.flake
          # } switch";

          gsed = "${getExe pkgs.gnused}";

          # File management
          rcp = "${getExe pkgs.rsync} -rahP --mkpath --modify-window=1"; # Rsync copy keeping all attributes,timestamps,permissions"
          rmv = "${getExe pkgs.rsync} -rahP --mkpath --modify-window=1 --remove-sent-files"; # Rsync move keeping all attributes,timestamps,permissions
          tarnow = "${getExe pkgs.gnutar} -acf ";
          untar = "${getExe pkgs.gnutar} -zxvf ";
          wget = "${getExe pkgs.wget} -c ";

          # Navigation shortcuts
          home = "cd ~";
          dots = "cd $DOTS_DIR";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "......" = "cd ../../../../..";

          # Colorize output
          dir = "${getExe' pkgs.coreutils "dir"} --color=auto";
          egrep = "${getExe' pkgs.gnugrep "egrep"} --color=auto";
          fgrep = "${getExe' pkgs.gnugrep "fgrep"} --color=auto";
          grep = "${getExe pkgs.gnugrep} --color=auto";
          vdir = "${getExe' pkgs.coreutils "vdir"} --color=auto";

          # Misc
          clear = "clear && ${getExe config.programs.fastfetch.package}";
          clr = "clear";
          pls = "sudo";
          usage = "${getExe' pkgs.coreutils "du"} -ah -d1 | sort -rn 2>/dev/null";

          # Cryptography
          genpass = "${getExe pkgs.openssl} rand - base64 20"; # Generate a random, 20-charactered password
          sha = "shasum -a 256"; # Test checksum
          sshperm = # bash
            ''${getExe' pkgs.findutils "find"} .ssh/ -type f -exec chmod 600 {} \;; ${getExe' pkgs.findutils "find"} .ssh/ -type d -exec chmod 700 {} \;; ${getExe' pkgs.findutils "find"} .ssh/ -type f -name "*.pub" -exec chmod 644 {} \;'';
        };

        username = mkDefault cfg.name;
      };

      programs.home-manager = {
        enable = true;
      };
      xdg = {
        enable = true;
      };

      # xdg.configFile = {
      #   "sddm/faces/.${cfg.name}".source = lib.mkIf (cfg.icon != null) cfg.icon;
      # };
    }
  ]);
}
