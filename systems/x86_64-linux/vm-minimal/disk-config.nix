{ lib, ... }:
{
  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = lib.mkDefault "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          canmount = "off";
          xattr = "sa";
          relatime = "on";
          normalization = "formD";
          mountpoint = "none";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          # keylocation = "prompt";
          keylocation = "file:///tmp/pass-zpool-rpool";
          compression = "zstd";
        };
        postCreateHook = ''
          zfs set keylocation="prompt" rpool
        '';
        options = {
          ashift = "12";
          autotrim = "on";
        };

        datasets = {
          local = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          data = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/reserved" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              reservation = "1GiB";
            };
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = { };
            postCreateHook = ''
              zfs snapshot rpool/local/root@blank
            '';
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
              canmount = "on";
            };
          };
          "data/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = { };
          };
          "data/persistent" = {
            type = "zfs_fs";
            mountpoint = "/persistent";
            options = { };
          };
        }; # datasets
      }; # rpool
    }; # zpool
  };
}
