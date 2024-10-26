{
  lib,
  ...
}:
let
  defaultBtrfsOpts = [
    "defaults"
    "compress=zstd:1"
  ];
  zramSwapWritebackSize = "4G";
  physicalSwapSize = "32G";
in
{
  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = lib.mkDefault "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            EFI = {
              priority = 1;
              name = "EFI";
              start = "1MiB";
              end = "1GiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [ "-n EFI" ];
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt-system";
                extraFormatArgs = [ "--label crypt-system" ];
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "lvm_pv";
                  vg = "lvm-crypt-system";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      lvm-crypt-system = {
        type = "lvm_vg";
        lvs = {
          zramSwapWriteBackDevice = {
            priority = 1;
            size = zramSwapWritebackSize;
            name = "zramSwapWritebackDevice";
          };
          physicalSwap = {
            priority = 2;
            size = physicalSwapSize;
            name = "swap";
            content = {
              type = "swap";
            };
          };
          root = {
            priority = 3;
            size = "100%FREE";
            name = "btrfs-root";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "--label btrfs-root"
              ];
              subvolumes = {
                "system" = { };
                "system/root" = {
                  mountpoint = "/";
                  mountOptions = defaultBtrfsOpts ++ [ "noatime" ];
                };
                "system/snapshots" = {
                  mountpoint = "/mnt/btrfs/snapshots";
                  mountOptions = defaultBtrfsOpts ++ [ "noatime" ];
                };
                "system/nix" = {
                  mountpoint = "/nix";
                  mountOptions = defaultBtrfsOpts ++ [ "noatime" ];
                };
                "system/var-log" = {
                  mountpoint = "/var/log";
                  mountOptions = defaultBtrfsOpts ++ [ "noatime" ];
                };
                "data" = { };
                "data/home" = {
                  mountpoint = "/home";
                  mountOptions = defaultBtrfsOpts ++ [ "relatime" ];
                };
                "data/persist" = {
                  mountpoint = "/persist";
                  mountOptions = defaultBtrfsOpts ++ [ "relatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
