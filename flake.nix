{
  description = "azmo Workstations Flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Run unpatched dynamically compiled binaries
    nix-ld-rs = {
      url = "github:nix-community/nix-ld-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hardware quirks
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    # Sops (Secrets)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Snowfall Lib
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Snowfall Flake
    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";

    catppuccin-cursors.url = "github:catppuccin/cursors";
    catppuccin.url = "github:catppuccin/nix";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
    };
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      snowfall = {
        namespace = "azmo-workstations";
        meta = {
          name = "azmo-workstations-flake";
          title = "Flake for azmo's Workstations";
        };
      };
      channels-config = {
        # Allow unfree packages
        allowUnfree = true;
      };
      systems = {
        hosts = {
          vm-minimal = { };
        };
        # Modules that get imported to every NixOS system
        modules.nixos = with inputs; [
          disko.nixosModules.disko
          # we always need sops for user generation
          sops-nix.nixosModules.sops
          # facter for hardware configuration
          nixos-facter-modules.nixosModules.facter
        ];
      };
      # add treefmt for nix fmt
      outputs-builder =
        channels:
        let
          treefmt = inputs.treefmt-nix.lib.evalModule channels.nixpkgs ./treefmt.nix;
        in
        {
          formatter = treefmt.config.build.wrapper;
          checks.formatting = treefmt.config.build.check inputs.self;
        };
    };
}
