{ pkgs, ... }:
{
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.services.serial-getty = {
    enable = true;
    description = "Serial Getty on ttyS0";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "@${pkgs.systemd}/bin/agetty --autologin root --noclear ttyS0 115200 linux";
      Restart = "always";
      Type = "idle";
    };
  };
}

