{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "backup" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "36ae9790";

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/cee8af6f-969f-4ba5-8c6a-5254491935dd";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/3512-A8AC";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/4b8c4158-95cf-4afb-85d4-13176b0cf062"; }];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
