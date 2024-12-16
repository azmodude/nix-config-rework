{
  lib,
  modulesPath,
  ...
}:
let
  installDisk = "/dev/disk/by-id/nvme-eui.002538bc61b3991c";
in
{
  imports = [
    ./disk-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  facter.reportPath = ./facter.json;

  disko.devices.disk.disk0.device = installDisk;

  hardware = {
    enableRedistributableFirmware = true;
  };
  services.thermald.enable = lib.mkDefault true;

}
