{
  config,
  inputs,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.nix;
in
{
  # shared nix settings. Useful if needed in e.g. nixos and darwin
  options.${namespace}.nix = {
    enable = mkBoolOpt true "Whether or not to manage nix configuration.";
    package = mkOpt lib.types.package pkgs.nixVersions.latest "Which nix package to use.";
  };

  config = lib.mkIf cfg.enable {
    # faster rebuilding
    documentation = {
      doc.enable = false;
      info.enable = false;
      man.enable = lib.mkDefault true;
    };

    environment.systemPackages = with pkgs; [
      cachix
      git
      nix-prefetch-git
    ];

    nix =
      let
        mappedRegistry = lib.pipe inputs [
          (lib.filterAttrs (_: lib.isType "flake"))
          (lib.mapAttrs (_: flake: { inherit flake; }))
          (x: x // (lib.mkIf pkgs.stdenv.isLinux { nixpkgs.flake = inputs.nixpkgs; }))
        ];

        users = [
          "root"
          "@wheel"
          "nix-builder"
          config.${namespace}.users.name
        ];
      in
      {
        inherit (cfg) package;

        distributedBuilds = true;

        gc = {
          automatic = true;
          options = "--delete-older-than 7d";
        };

        # This will additionally add your inputs to the system's legacy channels
        # Making legacy nix commands consistent as well
        nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

        optimise.automatic = pkgs.stdenv.isLinux;

        # pin the registry to avoid downloading and evaluating a new nixpkgs version every time
        # this will add each flake input as a registry to make nix3 commands consistent with your flake
        registry = mappedRegistry;

        settings = {
          allowed-users = users;
          auto-optimise-store = true;
          builders-use-substitutes = true;
          # TODO: pipe-operators throws annoying warnings
          experimental-features = [
            "nix-command "
            "flakes "
            "cgroups "
          ];
          flake-registry = "/etc/nix/registry.json";
          http-connections = 50;
          keep-derivations = true;
          keep-going = true;
          keep-outputs = true;
          log-lines = 50;
          sandbox = true;
          trusted-users = users;
          use-cgroups = true;
          warn-dirty = false;

          use-xdg-base-directories = true;
        };
      };
  };
}
