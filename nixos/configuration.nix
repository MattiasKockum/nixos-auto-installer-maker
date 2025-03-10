{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/Paris";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.default = {
    initialPassword = "nixos";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  networking.networkmanager.enable = true;
  #networking.firewall.allowedTCPPorts = [ 8000 ];

  system.stateVersion = "25.05"; # DON'T TOUCH

}
