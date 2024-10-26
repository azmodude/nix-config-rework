{ modulesPath, ... }:
let
  installDisk = "/dev/nvme0n1";
in
{
  imports = [
    ./disk-config.nix
    inputs.nixos-hardware.lenovo.thinkpad.p14s.amd.gen2
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  disko.devices.disk.disk0.device = installDisk;

  hardware = {
    enableRedistributableFirmware = true;
  };
}
