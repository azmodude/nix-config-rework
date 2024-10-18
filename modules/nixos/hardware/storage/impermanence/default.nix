{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.hardware.storage.impermanence;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.${namespace}.hardware.storage.impermanence = {
    enable = mkEnableOption "Enable impermanence";
  };

  config = lib.mkIf cfg.enable {
    fileSystems = {
      "/persistent".neededForBoot = true;
    };

    environment.persistence."/persistent" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/root"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
      ];
      files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/machine-id"
      ];
    };
    security.sudo.extraConfig = ''
      # Rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';

    services = {
      openssh = {
        hostKeys = [
          {
            path = "/persistent/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };
    };
  };
}
