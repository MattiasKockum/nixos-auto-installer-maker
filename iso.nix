{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    disko
    neovim
    nixos-install-tools
  ];

  # Ensure the kernel and bootloader support serial output
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

  systemd.services.auto-install = {
    enable = true;
    description = "Automatic NixOS Installation using Disko";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment="PATH=${pkgs.nixos-install-tools}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin:/run/current-system/sw/bin";
      ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeShellScript "auto-install" ''
        set -eux

        LOG_FILE="/var/log/auto-install.log"

        # Redirect all output to the log file
        exec > "$LOG_FILE" 2>&1

        echo "===== Starting Automatic NixOS Installation ====="
        date

        echo "Manually setting NIX_PATH..."
        export NIX_PATH=nixpkgs=${pkgs.path}

        echo "Current PATH: $PATH"

        echo "Running Disko..."
        ${pkgs.disko}/bin/disko --mode disko /etc/nixos/disko.nix

        echo "Generating NixOS configuration..."
        nixos-generate-config --root /mnt

        echo "Copying premade configuration"
        cp -r /etc/nixos/ /mnt/nixos/

        echo "Installing NixOS..."
        nixos-install --no-root-passwd

        echo "Installation Complete. Rebooting..."
        date
        reboot
      ''}";
    };
  };
}

