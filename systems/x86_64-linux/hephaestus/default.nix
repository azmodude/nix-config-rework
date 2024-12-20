{
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`). # The Snowfall Lib target for this system (eg. `x86_64-iso`). # A normalized name for the system target (eg. `iso`). # A boolean to determine whether this system is a virtual target using nixos-generators. # An attribute map of your defined hosts.
  # All other arguments come from the system system.
  ...
}:
{
  imports = [
    ../../common
    ./network.nix
    ./hardware.nix
    ./spezialization.nix
  ];

  ${namespace} = {
    archetypes = {
      workstation.enable = true;
    };
    hardware = {
      storage = {
        enable = true;
        ssdEnable = true;
        impermanence = {
          enable = true;
        };
        btrfs = {
          enable = false;
          autoScrub = true;
          scrubMounts = [
            "/"
          ];
          mountRoot = true;
          mountRootDevice = "/dev/disk/by-label/btrfs-root";
        };
        zfs = {
          enable = true;
          zrepl = {
            enable = true;
          };
        };
      };
    };
    nix = {
      enable = true;
    };
    services = {
      openssh = {
        enable = true;
      };
    };
    system = {
      boot = {
        systemd-boot = {
          enable = true;
        };
      };
      locale.enable = true;
    };
    users = {
      name = "azmo";
      uid = 1000;
      gid = 1000;
      sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUkEk7GV/qWMR9SJFYSJSxwnPxR8fG2Fn9VILHcyPYQ" ];
      root = {
        enable = true;
        sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUkEk7GV/qWMR9SJFYSJSxwnPxR8fG2Fn9VILHcyPYQ" ];
      };
    };
  };

  snowfallorg.users.azmo = {
    # create = true;
    # admin = true;
    #
    home = {
      enable = true;
    };
  };

  system.stateVersion = "24.11";
}
