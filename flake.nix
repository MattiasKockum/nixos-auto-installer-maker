{
  description = "NixOS Auto installer maker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url   = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, disko, configPath, ... }:
  let
    system = "x86_64-linux";
    pkgs   = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.autoInstallerFlakeSerial = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ ... }: {
          imports = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            disko.nixosModules.disko
          ];
          isoImage.squashfsCompression = "gzip -Xcompression-level 1";
          system.activationScripts.copy-nixos-files.text = ''
            mkdir -p /etc/premade-configuration
            cp -r ${configPath}/* /etc/premade-configuration/
          '';
        })
        ./iso/general-config.nix
        ./iso/serial-config.nix
        ./iso/auto-install-flake-service.nix
      ];
    };

    nixosConfigurations.autoInstallerFlakeVGA = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ ... }: {
          imports = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            disko.nixosModules.disko
          ];
          isoImage.squashfsCompression = "gzip -Xcompression-level 1";
          system.activationScripts.copy-nixos-files.text = ''
            mkdir -p /etc/premade-configuration
            cp -r ${configPath}/* /etc/premade-configuration/
          '';
        })
        ./iso/general-config.nix
        ./iso/auto-install-flake-service.nix
      ];
    };

  };
}

