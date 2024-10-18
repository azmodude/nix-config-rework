{ modulesPath, ... }:
let
  # installDisk = "/dev/vda";
  installDisk = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00001";
in
{
  imports = [
    ./disk-config.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  disko.devices.disk.disk0.device = installDisk;

  hardware = {
    enableRedistributableFirmware = true;
  };
}
