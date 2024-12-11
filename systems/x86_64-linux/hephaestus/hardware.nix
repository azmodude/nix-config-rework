{ inputs, modulesPath, ... }:
let
  installDisk = "/dev/disk/by-id/nvme-eui.0025388311b2ba65";
in
{
  imports = [
    ./disk-config.nix
    inputs.nixos-hardware.nixosModules.common.cpu.intel
    inputs.nixos-hardware.nixosModules.common.cpu.intel.kaby-lake
    inputs.nixos-hardware.nixosModules.common.pc.laptop.ssd
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  disko.devices.disk.disk0.device = installDisk;

  hardware = {
    enableRedistributableFirmware = true;
  };
  services.thermald.enable = lib.mkDefault true;

}
