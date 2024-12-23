{
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  inherit (inputs) pre-commit-hooks-nix;
in
pre-commit-hooks-nix.lib.${pkgs.system}.run {
  src = ./.;
  hooks =
    let
      excludes = [
        "flake.lock"
        "CHANGELOG.md"
      ];
      fail_fast = true;
      verbose = true;
    in
    {
      actionlint.enable = true;
      clang-format.enable = true;
      clang-tidy.enable = true;
      # conform.enable = true;
      commitizen.enable = true;

      deadnix = {
        enable = true;

        settings = {
          edit = true;
        };
      };

      eslint = {
        enable = true;
        package = pkgs.eslint_d;
      };

      git-cliff = {
        enable = false;
        inherit excludes fail_fast verbose;

        always_run = true;
        description = "pre-push hook for git-cliff";
        entry = "${lib.getExe pkgs.${namespace}.git-cliff}";
        language = "system";
        stages = [ "pre-push" ];
      };

      luacheck.enable = true;

      nixfmt-rfc-style.enable = true;

      pre-commit-hook-ensure-sops.enable = true;

      prettier = {
        enable = true;
        inherit excludes fail_fast verbose;

        description = "pre-commit hook for prettier";
        settings = {
          binPath = "${lib.getExe pkgs.prettierd}";
          write = true;
        };
      };
      gitleaks = {
        enable = true;
        name = "gitleaks";
        description = "Run gitleaks to check for credentials";
        entry = "${pkgs.gitleaks}/bin/gitleaks protect --verbose --redact --staged";
      };

      shfmt = {
        enable = true;

        excludes = [ ".*.p10k.zsh$" ];
      };

      statix = {
        enable = true;
      };
      #treefmt.enable = true;
    };
}
