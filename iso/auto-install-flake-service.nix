{ pkgs, ... }:
{
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
        ${pkgs.disko}/bin/disko --mode disko /etc/premade-configuration/disko.nix

        echo "Generating NixOS configuration..."
        nixos-generate-config --root /mnt

        echo "Copying premade configuration"
        HWCONF_PATH=$(find /etc/premade-configuration -type f -name "hardware-configuration.nix")
        if [[ -f "$HWCONF_PATH" ]]; then
            echo "Saving generated /mnt/etc/nixos/hardware-configuration.nix at $HWCONF_PATH"
            cp /mnt/etc/nixos/hardware-configuration.nix "$HWCONF_PATH"
        else
            echo "No hardware-configuration.nix file found. Be sure to know what you are doing."
        fi
        rm -rf /mnt/etc/nixos
        cp -r /etc/premade-configuration /mnt/etc/nixos

        echo "Installing NixOS..."
        cd /mnt/etc/nixos && nixos-install --no-root-passwd --flake ./#nixos

        echo "Installation Complete. Rebooting..."
        date
        reboot
      ''}";
    };
  };
}

