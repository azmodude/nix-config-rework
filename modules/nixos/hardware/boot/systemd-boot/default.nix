{
  config,
  lib,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.hardware.boot.systemd-boot;
in
{
  options.${namespace}.hardware.boot.systemd-boot = {
    enable = mkEnableOption "systemd-boot";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      consoleLogLevel = 0;
      initrd.verbose = true;
      kernelModules = [ "vhost_vsock" ];
      kernelParams = [ "udev.log_priority=3" ];
      # Only enable the systemd-boot on installs, not live media (.ISO images)
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          configurationLimit = 10;
          consoleMode = "max";
          enable = true;
          memtest86.enable = false;
        };
        timeout = 10;
      };
    };
  };
}
