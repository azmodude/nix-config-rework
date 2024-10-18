{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkDefault;
  inherit (lib.${namespace}) mkOpt;
  inherit (lib.types) listOf str;

  cfg = config.${namespace}.hardware.storage.zfs;

  #source: https://wiki.nixos.org/wiki/ZFS
  isUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (
      (!isUnstable && !kernelPackages.zfs.meta.broken)
      || (isUnstable && !kernelPackages.zfs_unstable.meta.broken)
    )
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  options.${namespace}.hardware.storage.zfs = {
    enable = mkEnableOption "ZFS support";
    zrepl = {
      enable = mkEnableOption "zrepl ZFS auto snapshotting.";
      filesystems = mkOpt (lib.types.attrsOf lib.types.bool) {
        "rpool/data<" = true;
      } "Datasets to snapshot.";
    };
    pools = mkOpt (listOf str) [ "rpool" ] "The ZFS pools to manage.";
    hostId = lib.mkOption {
      type = lib.types.str;
      description = "hostId for ZFS pools. Will be generated from hostName if not set.";
      default = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
    };
  };

  config = mkIf cfg.enable {
    boot = {
      kernelPackages = latestKernelPackage;
      zfs.requestEncryptionCredentials = true;
    };
    networking.hostId = cfg.hostId;

    services.zfs = {
      autoScrub = {
        enable = true;
        inherit (cfg) pools;
      };
    };

    services.zrepl =
      let
        inherit (cfg.zrepl) filesystems;
      in
      {
        enable = true;
        settings = {
          jobs = [
            {
              name = "snapjob";
              type = "snap";
              filesystems = { } // filesystems; # merge two attrsets
              snapshotting = {
                type = "periodic";
                interval = "15m";
                prefix = "zrepl_";
              };
              pruning = {
                keep = [
                  {
                    type = "grid";
                    grid = "1x1h(keep=all) | 24x1h | 14x1d";
                    regex = "^zrepl_.*";
                  }
                  {
                    type = "regex";
                    negate = true;
                    regex = "^zrepl_.*";

                  }
                ];
              };
            }
          ];
        };
      };

    # rollback root filesystem if impermanence is set
    boot.initrd.systemd.enable = lib.mkIf config.${namespace}.hardware.storage.impermanence.enable true;
    boot.initrd.systemd.services.initrd-rollback-root =
      lib.mkIf config.${namespace}.hardware.storage.impermanence.enable
        {
          description = "Rollback root filesystem to a pristine state on boot";
          wantedBy = [
            "initrd.target"
          ];
          after = [
            "zfs-import-rpool.service"
          ];
          before = [
            "sysroot.mount"
            "local-fs.target"
          ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.zfs}/sbin/zfs rollback -r rpool/local/root@blank";
          };
        };
  };
}
