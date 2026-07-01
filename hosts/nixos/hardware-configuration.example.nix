# Template hardware config — copy to hardware-configuration.nix and regenerate on your machine:
#   cp hosts/nixos/hardware-configuration.example.nix hosts/nixos/hardware-configuration.nix
#   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
#
# hardware-configuration.nix is gitignored; only this example is committed.
{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
