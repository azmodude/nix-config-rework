{ inputs, modulesPath, ... }:
let
  #installDisk = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00001";
  installDisk = "/dev/disk/by-id/nvme-eui.0025388311b2ba65";
in
{
  imports = [
    ./disk-config.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  disko.devices.disk.disk0.device = installDisk;

  hardware = {
    enableRedistributableFirmware = true;
  };
}
